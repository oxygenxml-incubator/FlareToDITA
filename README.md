# Convert Madcap Flare projects to DITA XML (Experimental)


## What the project does:

  - Creates a DITA Map from the table of contents file.
  - Creates a plain DITA XML topic for each HTML file.
    - Converts HTML tables to DITA XML tables.
    - Converts Flare variables and reusable content to DITA XML key references or content references.
    - Converts Flare change tracking markers and comments to Oxygen XML change tracking markers and comments.
    - Converts Flare links to DITA XML links.

Limitations:

  - There is no support yet for profiling attributes migrations.
  - The table column widths and cell/row spans are not taken into account.
  - There is no support yet for creating DITAVAL filter files.
  - Headings are usually converted to plain DITA XML paragraphs with bold text so they need to be manually converted to DITA XML sections or inner topics.
  
  
## How to use it to migrate your Flare project to DITA using Oxygen XML Editor/Author

- Install Oxygen XML Editor/Author.
- Download and unzip the [project](https://codeload.github.com/oxygenxml-incubator/FlareToDITA/zip/refs/heads/main).
- Copy your Flare project into the **flareProject** folder. The content of your Flare Project should look like this:
```
[this folder]
  _rels
  Content
  Project
  [Content_Types].xml
  EmployeeManual.flprj
```

- Start Oxygen, go to **Project -> Open project** and open the **flareToDita.xpr**.
- In the **Project** view, right click the **flareToDITA.xsl** file and in the contextual menu select **Transform->Apply Transformation Scenario(s)**.

### Result

The DITA Map is generated in the location *flareProject/f/Project/TOCs/TOC.ditamap* and a *\*.dita* file will be generated next to every *\*.htm* file.

Open the DITA Map in the **Oxygen** **DITA Maps Manager** view and use the **Validate and check for completeness** toolbar action to check if it is valid. If there are validation problems you can add issues on this project with details about what the original HTML content looks like and what the validation error is. Taking into account the limitations listed above you should also open side by side each original HTML file and generated DITA XML topic and double check if the content was properly migrated.



## Publishing to WebHelp or PDF

The ditamap should be opened automatically in the **DITA Maps Manager**, but, just in case it doesn't, locate it inside the **Project** view and double click it.

- In the **DITA Maps Manager** view, on the toolbar, click the **Configure transformation scenario(s)** button
- In the **Configure transformation scenario(s)** dialog, select **DITA Map WebHelp Responsive** and click **Duplicate** from under the list
- Go on the **Parameters** tab and set the **fix.external.refs.com.oxygenxml** parameter to true (it needs to be set because the **DITA Map** refers to resources outside its folder, as it mirrors the flare project).
- Click **OK** and then **Apply Associated**.

To Obtain a PDF perform the above procedure again, but this time use the **DITA Map PDF - based on HTML5 & CSS** scenario

