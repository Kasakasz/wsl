<!DOCTYPE html>
<title>Resume</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/casualwriter/casual-markdown/dist/casual-markdown.css">
<script src="https://cdn.jsdelivr.net/gh/casualwriter/casual-markdown/dist/casual-markdown.js"></script>
<script src="html2pdf.bundle.min.js"></script>

<style>
  body { line-height:1.5; margin:auto; padding:3px; max-width:1024px; FONT-FAMILY:"Segoe UI",ARIAL; background-color: white; color: black}
  h1  { font-size:110%; color: green; font-weight: bold; border-bottom: 1px solid black}
  h2  { border-bottom:1px solid grey;}
</style>
<body onload="document.body.innerHTML=md.html(document.body.innerHTML); document.body.style.display='block';">
<!--======= COPY ABOVE CODE AS HEADER, THEN FOLLOW WITH RESUME CONTENT IN MARKDOWN FORMAT =========-->
<style>
.topLine {border-top: 3px solid green}
.topDiv {display: grid;justify-content: center; padding: 15px}
.leftDiv {padding: 10px; border-right: 3px solid green}
.rightDiv {padding: 10px; padding-left: 20px; border-bottom: 3px solid green}
</style>
<div id="dvContainer">
<div class="topDiv">
<div style="display: grid;justify-content: center;font-size:150%;">
Krzysztof Gawliński
</div></br><div style="display: grid;justify-content: center;font-size:120%">Senior Salesforce Developer / Tech Lead / Certified Application Architect</div></br>
</div>
<div style="display: flex;justify-content: space-around;">
<div class="topLine leftDiv">
<h1>Contact</h1>

Warszawa 
+48 793 323 588 
k.gawlinski@hotmail.com</br>
<a href="https://www.linkedin.com/in/krzysztof-gawlinski-salesforce-dev/">LinkedIn Profile </a>

<h1>Education</h1>

University of Mechatronics, Katowice,
Engineer of Mechatronics

<h1>Languages</h1>

English – fluent 
Polish – native 

<h1>Skills</h1>

diligence, teamwork, self-education, communication skills, accuracy, independence</br>

<h1>Interests</h1>

Mountain hiking, music, programming, pen and paper games (e.: DnD), board games, video games</br>
</div>
<div class="topLine rightDiv">
Senior Salesforce developer with 8 years of experience in software development, supporting of deployed project and integration of existing IT systems with new elements of architecture. Specializes in designing and implementation of the best solutions tailored to customer needs.</br>

<h1>Experience</h1>

<b>BEC Poland / Nykredit / Scoutz</b></br>

 08.2021 – present • <b>Senior Salesforce Developer / Lead Developer / Tech Lead</b></br>

<b>Responsibilities</b>

• Creating process for packaged feature delivery,</br>
• Implementing features in packages with dependency-less approach,</br>
• Extending Salesforce software based on business requirements using Apex, SOQL, JS, LWC,</br>
• Implementing self service on Salesforce community cloud,</br>
• Leading in implementation of development guidelines for new company structure (Scoutz),</br>
• Introducing and implementing new frameworks,</br>
• Mentoring experienced developers in Salesforce platform</br>

<b>PwC IT Services</b>

 04.2020 – 07.2021 • <b>Senior Salesforce Developer</b></br>
 04.2017 – 04.2020 • <b>Salesforce Devloper</b></br>
 01.2016 – 04.2017 • <b>Junior Salesforce Devloper</b></br>

<b>Responsibilities</b>

• Working with architects to create high level design and implement requirements,</br>
• Sharing knowledge with less experienced developers on project and supporting their development skills,</br>
• Extending Salesforce software based on business requirements using Apex, SOQL, JS, LWC,</br>
• Experience with Salesforce community cloud, Salesforce service cloud,</br>
• Driving code conventions and code quality on projects,</br>
• Working on projects of different sizes (from 1 up to ~250 developers).</br>

<h1>Technical Skills</h1>

• Programming – Apex, JS, Aura, LWC, Visualforce, HTML/CSS, Java, Shell scripting (Entry level)</br>
• Os – Windows, Linux(Entry level)</br>
• CI/CD – SFDX/SF, GIT, Jenkins, TeamCity, Github, Bitbucket</br>
• Familiar IDE – Visual Studio Code, Webstorm, Illuminated Cloud</br>

<h1>Certificates</h1>

Salesforce Certified Application Architect • 12.2023</br>
Salesforce Certified Sharing and Visibility Architect • 12.2023</br>
Salesforce Certified Data Architecture and Management Design • 08.2020</br>
Salesforce Certified Platform Developer II • 02.2020</br>
Salesforce Certified Service Cloud Consultant • 06.2018</br>
Salesforce Certified Platform Developer I • 04.2017</br>
Salesforce Certified Platform App Builder • 02.2017</br>
Salesforce Certified Administrator • 03.2016</br>
</div>
</div>
<input id="pdfButton" type="button" value="print to pdf">
</div>
<script>
  const btn = document.getElementById("pdfButton");
  btn.addEventListener("click", function(){
  var element = document.getElementById('body');
  html2pdf().from(element).save('filename.pdf');
  });
</script>