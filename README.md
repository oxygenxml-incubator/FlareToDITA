# Convert Madcap Flare projects to DITA XML


## What the project does:

  - Creates a DITA Map from the table of contents file.
  - Creates a plain DITA XML topic for each HTML file.
    - Converts HTML tables to DITA XML tables.
    - Converts Flare variables and reusable content to DITA XML key references or content references.
    - Converts Flare change tracking markers and comments to Oxygen XML change tracking markers and comments.
    - Converts Flare links to DITA XML links.

Limitations:

  - There is no support yet for profiling attributes migrations.
  - There is no support yet for creating DITAVAL filter files.
  - Headings are usually converted to plain DITA XML paragraphs with bold text so they need to be manually converted to DITA XML sections or inner topics.
  
  
## How to use it to migrate your Flare project to DITA

- install Oxygen XML Author

- unzip the attached project

- copy your Flare project into the flareProject sub folder. It's conent should look like this:
```
[this folder]
  _rels
  Content
  Project
  [Content_Types].xml
  EmployeeManual.flprj
```

- start Oxygen, go to Project -> Open project and open the flareToDita.xpr

- in the Project view, invoke the contextual menu over flareToDITA.xsl and select Transform->Apply Transformation Scenario(s)

### Result

The ditamap is generated in *flareProject/f/Project/TOCs/TOC.ditamap* and a *\*.dita* file will be generated next to every *\*.htm* file.



## Publishing to WebHelp or PDF

The ditamap should be opened automatically in the DITA Maps Manager, but,  just in case it doesn't, locate it inside the Project view and double click it.

- in the DITA Maps Manager view, on the toolbar, click the Configure transformation scenario(s) button

- in the dialog, select DITA Map WebHelp Responsive and click Duplicate from under the list


- go on the Parameters tab and set the fix.external.refs.com.oxygenxml parameter to true (it needs to be set because the DITA Map refers to resources outside its folder, as it mirrors the flare project)


- Click OK and then Apply Associated


To Obtain a PDF perform the above procedure again, but this time use the DITA Map PDF - based on HTML5 & CSS scenario

