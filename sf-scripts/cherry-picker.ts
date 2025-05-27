import { exec } from 'child_process';
import * as process from "node:process";
import axios from 'axios';
import { HttpsProxyAgent, HttpProxyAgent } from "hpagent";

const storyNumberParam = '--story-number';
const snParam = '-sn';
const repoParam = '--repository';
const rParam = '-r';
const releaseBranchParam = '--release-branch';
const rbParam = '-rb';
const fixVersionParam = '--fix-version';
const fvParam = '-fv';

let releaseBranchName = 'release';

const args = process.argv.slice(2);
let map = new Map();
map.set(releaseBranchName, 'release');
map.set(rbParam, 'release');
let currentKey = String();
args.forEach((arg) => {
    if (arg.startsWith('--') || arg.startsWith('-')) {
        if (currentKey === releaseBranchParam || currentKey === rbParam) {
            map.delete(releaseBranchParam);
            map.delete(rbParam);
        } else if (currentKey === storyNumberParam || currentKey === snParam) {
            currentKey = arg;
            let storyNumbers: any[] = new Array();
            map.set(currentKey, storyNumbers);
        } else {
            currentKey = arg;
        }
    } else {
        if(currentKey === storyNumberParam || currentKey === snParam) {
            let storyNumbers: any[] = map.has(currentKey) ? map.get(currentKey) : new Array();
            storyNumbers.push(arg);
            map.set(currentKey, storyNumbers);
        } else {
            map.set(currentKey, arg);
        }
    }
})

function getParamByNamesOptional(name: string, secondName:String, isOptional: boolean) {
    let returnParam = map.has(name) ? map.get(name) : map.has(secondName) ? map.get(secondName) : null;

    if (returnParam === null && !isOptional) {
        console.error(`param ${name} or ${secondName} not provided - exiting`);
        process.exit(3);
    }
    return returnParam;
}

function getParamByNames(name: string, secondName:string) {
    return getParamByNamesOptional(name, secondName, false);
}

function getIssueNumbers() {
    return getParamByNames(storyNumberParam, snParam);
}

function getRepositoryName() {
    return getParamByNames(repoParam, rParam);
}

function getReleaseBranch() {
    return getParamByNames(releaseBranchParam, rbParam);
}

function getFixVersion() {
    return getParamByNames(fixVersionParam, fvParam);
}

const JIRA_INSTANCE = 'jiraInstanceHere';
const API_TOKEN = 'pasteYourTokenFromJiraHere'; // Replace with your Jira API token

async function getIssueId(issueNumber: string) {
    const storyInfoUrl = `${JIRA_INSTANCE}/jira/rest/api/2/issue/${issueNumber}`;
    const response = await axios.get(storyInfoUrl, {
        headers: {
            'Authorization': `Bearer ${API_TOKEN}`,
        }
    });
    return response.data.id;
}

async function getStoriesForFixVersion(fixVersion: string) {
    const queryUrl = `${JIRA_INSTANCE}/jira/rest/api/2/search?jql=fixVersion="${fixVersion}"&&fields=issueNumber`;
    const response = await axios.get(queryUrl,{
        headers: {
            'Authorization': `Bearer ${API_TOKEN}`,
        }
    });

    return response.data.issues;
}

async function getCommitsFromFixVersion() {
    const stories = await getStoriesForFixVersion(getFixVersion());
    let commits: any[] = [];
    let commitHashes: string[] = [];
    for (const story of stories) {
        let storyInfo = await makeCall(`${JIRA_INSTANCE}/jira/rest/dev-status/latest/issue/detail?issueId=${story.id}&applicationType=stash&dataType=repository`);
        if (storyInfo.length >= 1) {
            commits.push(...storyInfo);
        }
    }

    commits.sort((a: { authorTimestamp: string | number | Date; }, b: {
        authorTimestamp: string | number | Date;
    }) => {
        const dateA = new Date(a.authorTimestamp).getTime();
        const dateB = new Date(b.authorTimestamp).getTime();
        return dateA - dateB
    });
    commits.forEach((commit: { id: string;}) => {
        commitHashes.push(commit.id);
    })

    return commitHashes;
}

async function makeCall(url: string) {
    console.log('getting story data from ', url);
    let commitsToReturn: any[] = [];
    const repositoryName = getRepositoryName();
    try {
        const response = await axios.get(url, {
            headers: {
                'Authorization': `Bearer ${API_TOKEN}`,
            }
        });
        const repositories = response.data.detail[0].repositories;
        repositories.forEach((repository: { name: string, commits: any; }) => {
            if (repository.name !== repositoryName) {
                return;
            }
            commitsToReturn = repository.commits;
            commitsToReturn.sort((a: { authorTimestamp: string | number | Date; }, b: {
                authorTimestamp: string | number | Date;
            }) => {
                const dateA = new Date(a.authorTimestamp).getTime();
                const dateB = new Date(b.authorTimestamp).getTime();
                return dateA - dateB
            });
        })
    } catch (error) {
        console.error(error);
        process.exit(1);
    }
    return commitsToReturn;
}

async function getCommitsForStories(storyNumbers: string[]) {
    let commits: any[] = [];
    let commitHashes: string[] = [];
    for (const storyNumber of storyNumbers) {
        let issueId: string = await getIssueId(storyNumber);
        commits.push(...await makeCall(`${JIRA_INSTANCE}/jira/rest/dev-status/latest/issue/detail?issueId=${issueId}&applicationType=stash&dataType=repository`));
    }
    commits.sort((a: { authorTimestamp: string | number | Date; }, b: {
        authorTimestamp: string | number | Date;
    }) => {
        const dateA = new Date(a.authorTimestamp).getTime();
        const dateB = new Date(b.authorTimestamp).getTime();
        return dateA - dateB
    });
    commits.forEach((commit: { id: string;}) => {
        commitHashes.push(commit.id);
    })
    return commitHashes;
}

function checkoutIntoReleaseBranch() {
    exec(`git checkout ${getReleaseBranch()}`, (error, stdout, stderr) => {
        if (error) {
            console.error(`exec error: ${error}`);
            process.exit(1);
        }

        console.log(`stdout: ${stdout}`);
        console.warn(`stderr: ${stderr}`);
    });
}

function callGitFetch() {
    exec(`git fetch`, (error, stdout, stderr) => {
        if (error) {
            console.error(`exec error: ${error}`);
            process.exit(1);
        }

        console.log(`stdout: ${stdout}`);
        console.warn(`stderr: ${stderr}`);
    });
}

async function cherryPickCommits() {
    callGitFetch();
    checkoutIntoReleaseBranch();
    if (process.env.HTTPS_PROXY && process.env.HTTP_PROXY) {
        axios.defaults.proxy = false;
        axios.defaults.httpsAgent = new HttpsProxyAgent({
            proxy: process.env.HTTPS_PROXY,
        });
        axios.defaults.httpAgent = new HttpProxyAgent({
            proxy: process.env.HTTPS_PROXY,
        });
    }
    let commitHashes: string[] = [];
    if (getParamByNamesOptional(storyNumberParam, snParam, true)) {
        commitHashes.push(...await getCommitsForStories(getIssueNumbers()));
    } else if (getParamByNamesOptional(fixVersionParam, fvParam, true)) {
        commitHashes.push(...await getCommitsFromFixVersion());
    }

    if (commitHashes.length === 0) {
        console.error('no commits for cherrypicking found');
        process.exit(1);
    }
    console.log('commit hashes that will be used in cherrypick in order ', commitHashes);
    let commitHashesString: string = commitHashes.join(' ');
    exec(`git cherry-pick ${commitHashesString} --empty=drop -m 1`, (error, stdout, stderr) => {
        if (error) {
            console.error(`exec error: ${error}`);
            process.exit(1);
        }

        console.log(`stdout: ${stdout}`);
        console.warn(`stderr: ${stderr}`);
    });
}
cherryPickCommits();
