# Convert Madcap Flare projects to DITA XML

The XSLT can be applied over itself (by creating a transformation scenario in Oxygen for example).
There is a parameter **FlareProjectFolder** which needs to be set to the folder where the Flare project is placed (the folder containing the **Analyzer/Content/Output/Project** subfolders).
The XSLT will create DITA Maps and Topics in the same folders where the Flare resources are located.
The main created DITA Map is created in the **Project/TOCs/** folder and for each HTML file a DITA XML topic is created next to it.
When publishing the DITA Map as it refers to resources outside its folder, if you are using Oxygen XML for publishing this specific publishing parameter must be set:
https://www.oxygenxml.com/doc/ug-editor/topics/dita-ot-external-refs.html

What the XSLT does:

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
  

