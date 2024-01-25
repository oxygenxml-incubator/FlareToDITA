<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:mml="http://www.w3.org/1998/Math/MathML"
    xmlns:m="http://www.w3.org/1998/Math/MathML"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs funct MadCap mml"
    version="2.0" xmlns:MadCap="http://www.madcapsoftware.com/Schemas/MadCap.xsd"
    xmlns:funct="http://www.someNamespace.com">
    <xsl:param name="FlareProjectFolder"/>
    <xsl:param name="FlareProjectFolderURL" select="funct:toUrl($FlareProjectFolder)"/>

    <!-- Create corresponding DITA XML files in the same folder where the Flare resources are placed. -->
    <xsl:template match="/">
        <!-- HTML -> DITA XML topics -->
        <xsl:for-each
            select="collection(concat($FlareProjectFolderURL, '/?select=*.htm;recurse=yes'))">
            <xsl:apply-templates select="." mode="htmlToDITA"/>
        </xsl:for-each>

        <!-- TOC to DITA Map -->
        <xsl:for-each
            select="collection(concat($FlareProjectFolderURL, '/?select=*.fltoc;recurse=yes'))">
            <xsl:apply-templates select="." mode="toc"/>
        </xsl:for-each>

        <!-- Reused content topics -->
        <xsl:for-each
            select="collection(concat($FlareProjectFolderURL, '/?select=*.flsnp;recurse=yes'))">
            <xsl:apply-templates select="." mode="flsnp"/>
        </xsl:for-each>

        <!-- Variable names. -->
        <xsl:for-each
            select="collection(concat($FlareProjectFolderURL, '/?select=*.flvar;recurse=yes'))">
            <xsl:apply-templates select="." mode="flvar"/>
        </xsl:for-each>
    </xsl:template>

    <!-- HTML -> DITA XML topics -->
    <xsl:template match="/" mode="flsnp">
        <xsl:variable name="fileNameNoExt" select="funct:getFileNameNoExt(base-uri())"/>
        <xsl:result-document doctype-system="topic.dtd"
            doctype-public="-//OASIS//DTD DITA Topic//EN"
            href="{resolve-uri(concat($fileNameNoExt, '.dita'), base-uri())}" indent="true">
            <topic id="reusable">
                <title>Reusable content</title>
                <body>
                    <div id="reusableComponent">
                        <xsl:apply-templates select="/html/body/*" mode="htmlToDITA"/>
                    </div>
                </body>
            </topic>
        </xsl:result-document>
    </xsl:template>

    <!-- Variable names to DITA Maps. -->
    <xsl:template match="/" mode="flvar">
        <xsl:variable name="fileNameNoExt" select="funct:getFileNameNoExt(base-uri())"/>
        <xsl:result-document doctype-system="map.dtd" doctype-public="-//OASIS//DTD DITA Map//EN"
            href="{resolve-uri(concat($fileNameNoExt, '.ditamap'), base-uri())}" indent="true">
            <map>
                <title>Variables</title>
                <xsl:apply-templates mode="flvar"/>
            </map>
        </xsl:result-document>
    </xsl:template>

    <xsl:template match="/*" mode="flvar">
        <xsl:apply-templates mode="flvar"/>
    </xsl:template>

    <xsl:template match="Variable" mode="flvar">
        <keydef keys="{concat(funct:getFileNameNoExt(base-uri()), '.', funct:validKeyName(@Name))}">
            <topicmeta>
                <keywords>
                    <keyword>
                        <xsl:value-of select="."/>
                    </keyword>
                </keywords>
            </topicmeta>
        </keydef>
    </xsl:template>

    <!-- TOC to DITA Map. -->
    <xsl:template match="/" mode="toc">
        <xsl:variable name="fileNameNoExt" select="funct:getFileNameNoExt(base-uri())"/>
        <xsl:result-document doctype-system="map.dtd" doctype-public="-//OASIS//DTD DITA Map//EN"
            href="{resolve-uri(concat($fileNameNoExt, '.ditamap'), base-uri())}" indent="true">
            <map>
                <xsl:variable name="firstTOCEntry" select="(//TocEntry)[1]"/>
                <xsl:if test="$firstTOCEntry">
                    <xsl:variable name="hrefRel" select="concat('../..', $firstTOCEntry/@Link)"/>
                    <xsl:if test="doc-available(resolve-uri($hrefRel, base-uri()))">
                        <xsl:variable name="title" select="(document($hrefRel, .)//p[@class='title'])[1]"/>
                        <xsl:if test="$title">
                            <title>
                                <xsl:apply-templates select="$title/node()" mode="htmlToDITA"/>
                            </title>
                        </xsl:if>
                    </xsl:if>
                </xsl:if>
                <xsl:apply-templates mode="toc"/>
                <!-- Add mapref to reusable variable files -->
                <topicgroup id="Variables">
                    <xsl:for-each
                        select="collection(concat($FlareProjectFolderURL, '/?select=*.flvar;recurse=yes'))">
                        <mapref href="../VariableSets/{funct:getFileNameNoExt(base-uri())}.ditamap"
                        />
                    </xsl:for-each>
                </topicgroup>
            </map>
        </xsl:result-document>
    </xsl:template>

    <xsl:template match="/*" mode="toc">
        <xsl:apply-templates mode="toc"/>
    </xsl:template>

    <xsl:template match="TocEntry" mode="toc">
        <xsl:variable name="href">
            <xsl:choose>
                <xsl:when test="contains(@Link, '.htm#')">
                    <xsl:value-of select="replace(@Link, '.htm#(.*)', '.dita')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="replace(@Link, '.htm', '.dita')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <topicref href="../..{funct:correctURL($href)}">
            <xsl:apply-templates select="*"/>
        </topicref>
    </xsl:template>

    <!-- HTML to DITA XML Topic. -->
    <xsl:template match="/" mode="htmlToDITA">
        <xsl:variable name="fileNameNoExt" select="funct:getFileNameNoExt(base-uri())"/>
        <xsl:result-document doctype-system="topic.dtd"
            doctype-public="-//OASIS//DTD DITA Topic//EN"
            href="{resolve-uri(concat($fileNameNoExt, '.dita'), base-uri())}" indent="true">
            <topic id="topic">
                <title>
                    <xsl:apply-templates
                        select="((/html/body/*[@class = 'Title_1' or @class='title'] | (/html/body/h1)[1][count(preceding-sibling::*) = 0])[1])/node()"
                        mode="htmlToDITA"/>
                </title>
                <xsl:apply-templates mode="htmlToDITA"/>
            </topic>
        </xsl:result-document>
    </xsl:template>

    <!-- Copy template. -->
    <xsl:template match="node() | @*" mode="htmlToDITA">
        <xsl:copy copy-namespaces="no">
            <xsl:apply-templates select="node() | @*" mode="htmlToDITA"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="head" mode="htmlToDITA"/>
    <xsl:template match="html" mode="htmlToDITA" priority="20">
        <xsl:apply-templates select="body" mode="htmlToDITA"/>
    </xsl:template>
    <xsl:template match="body" mode="htmlToDITA">
        <body>
            <xsl:apply-templates mode="htmlToDITA"/>
        </body>
    </xsl:template>

    <!-- Title -->
    <xsl:template
        match="((/html/body/*[@class = 'Title_1' or @class='title'] | /html/body/h1[count(preceding-sibling::*) = 0]))[1]"
        mode="htmlToDITA" priority="10"/>

    <!-- Class to outputclass attr -->
    <xsl:template match="@class" mode="htmlToDITA">
        <xsl:attribute name="outputclass" select="."/>
    </xsl:template>
    
    <!-- No support for this -->
    <xsl:template match="@MadCap:*" mode="htmlToDITA"/>
    <xsl:template match="@style|@cellspacing|@start" mode="htmlToDITA"/>
    
    <!-- Heading to paragraph with bold content -->
    <xsl:template match="*[starts-with(local-name(), 'h')]" mode="htmlToDITA">
        <p>
            <xsl:apply-templates select="@*" mode="htmlToDITA"/>
            <b>
                <xsl:apply-templates mode="htmlToDITA" select="node()"/>
            </b>
        </p>
    </xsl:template>

    <!-- Anchor -->
    <xsl:template match="a[@name]" mode="htmlToDITA">
        <ph id="{@name}">
            <xsl:apply-templates mode="htmlToDITA"/>
        </ph>
    </xsl:template>
    
    <xsl:template match="br" mode="htmlToDITA">
        <xsl:processing-instruction name="linebreak"/>
    </xsl:template>

    <!-- External link -->
    <xsl:template match="a[@href]" mode="htmlToDITA">
        <xref href="{@href}" scope="external" format="html">
            <xsl:apply-templates mode="htmlToDITA"/>
        </xref>
    </xsl:template>
    
    <!-- MathML -->
    <xsl:template match="mml:*" mode="htmlToDITA">
        <xsl:element name="m:{local-name()}" namespace="http://www.w3.org/1998/Math/MathML">
            <xsl:apply-templates mode="htmlToDITA"/>
        </xsl:element>
    </xsl:template>

    <!-- Internal link -->
    <xsl:template match="*:xref[@href]" mode="htmlToDITA">
        <xsl:variable name="href">
            <xsl:choose>
                <xsl:when test="contains(@href, '.htm#')">
                    <xsl:value-of select="replace(@href, '.htm#', '.dita#topic/')"/>
                </xsl:when>
                <xsl:when test="starts-with(@href, '#')">
                    <xsl:value-of select="concat('#', './', substring(@href, 2))"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="replace(@href, '.htm', '.dita')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xref href="{$href}">
            <xsl:apply-templates mode="htmlToDITA"/>
        </xref>
    </xsl:template>

    <!-- Image -->
    <xsl:template match="img" mode="htmlToDITA">
        <image href="{funct:correctURL(@src)}">
            <xsl:apply-templates mode="htmlToDITA"/>
        </image>
    </xsl:template>

    <!-- Variable reference -->
    <xsl:template match="*[local-name() = 'variable']" mode="htmlToDITA">
        <ph keyref="{funct:validKeyName(@name)}">
            <xsl:apply-templates/>
        </ph>
    </xsl:template>

    <!-- Ignore -->
    <xsl:template match="*[local-name() = ('tocProxy', 'miniTocProxy', 'microContent')]" mode="htmlToDITA"/>

    <!-- Insert and delete change tracking -->
    <xsl:template match="*:change" mode="htmlToDITA">
        <xsl:variable name="id" select="@*:changes"/>
        <!-- <?oxy_insert_start author="raducoravu" timestamp="20231209T132337+0200"?> -->
        <xsl:variable name="changeElem" select="//*:changeData/*[@*:id = $id]"/>
        <xsl:variable name="isInsertChange" as="xs:boolean"
            select="local-name($changeElem) = 'AddChange'"/>
        <xsl:choose>
            <xsl:when test="$isInsertChange">
                <xsl:processing-instruction name="oxy_insert_start">
                    author="<xsl:value-of select="$changeElem/@*:userName"/>"
                    timestamp="<xsl:value-of select="funct:processTimestamp($changeElem/@*:timestamp)"/>"
                </xsl:processing-instruction>
            </xsl:when>
            <xsl:when test="local-name($changeElem) = 'RemoveChange'">
                <xsl:processing-instruction name="oxy_delete">
                    content="<xsl:apply-templates select="node()" mode="htmlToDITA"/>"
                    author="<xsl:value-of select="$changeElem/@*:userName"/>"
                    timestamp="<xsl:value-of select="funct:processTimestamp($changeElem/@*:timestamp)"/>"
                </xsl:processing-instruction>
            </xsl:when>
        </xsl:choose>
        <xsl:if test="$isInsertChange">
            <xsl:apply-templates select="node()" mode="htmlToDITA"/>
        </xsl:if>
        <xsl:if test="$isInsertChange">
            <xsl:processing-instruction name="oxy_insert_end"/>
        </xsl:if>
    </xsl:template>

    <!-- Colspec, ignore for now -->
    <xsl:template match="col" mode="htmlToDITA"/>
    <!-- HTML table to DITA XML table -->
    <xsl:template match="table" mode="htmlToDITA">
        <xsl:copy copy-namespaces="no">
            <xsl:apply-templates select="@*" mode="htmlToDITA"/>
            <tgroup cols="{count((.//tr)[1]/*)}">
                <xsl:choose>
                    <xsl:when test="tr">
                        <tbody>
                            <xsl:apply-templates select="node()" mode="htmlToDITA"/>
                        </tbody>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="node()" mode="htmlToDITA"/>
                    </xsl:otherwise>
                </xsl:choose>
            </tgroup>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="tr" mode="htmlToDITA">
        <row>
            <xsl:apply-templates mode="htmlToDITA"/>
        </row>
    </xsl:template>
    <xsl:template match="th | td" mode="htmlToDITA">
        <entry>
            <xsl:apply-templates mode="htmlToDITA"/>
        </entry>
    </xsl:template>

    <!-- Change tracking comment -->
    <xsl:template match="*:annotation" mode="htmlToDITA">
        <xsl:processing-instruction name="oxy_comment_start">
            author="<xsl:value-of select="@*:creator"/>"
            timestamp="<xsl:value-of select="funct:processTimestamp(@*:createDate)"/>"
            comment="<xsl:value-of select="funct:processTimestamp(@*:comment)"/>"
        </xsl:processing-instruction>
        <xsl:apply-templates select="node()" mode="htmlToDITA"/>
        <xsl:processing-instruction name="oxy_comment_end"/>
    </xsl:template>

    <!-- Terms -->
    <xsl:template match="*[@term]" mode="htmlToDITA">
        <keyword outputclass="{local-name()}">
            <xsl:value-of select="@term"/>
            <xsl:apply-templates mode="htmlToDITA"/>
        </keyword>
    </xsl:template>

    <xsl:template match="span" mode="htmlToDITA">
        <ph>
            <xsl:apply-templates mode="htmlToDITA"/>
        </ph>
    </xsl:template>
    
    <xsl:template match="blockquote" mode="htmlToDITA">
        <q>
            <xsl:apply-templates mode="htmlToDITA"/>
        </q>
    </xsl:template>

    <xsl:template match="*:equation" mode="htmlToDITA">
        <mathml>
            <xsl:apply-templates mode="htmlToDITA"/>
        </mathml>
    </xsl:template>

    <xsl:template match="*:qrCode" mode="htmlToDITA">
        <codeblock outputclass="{local-name()}">
            <xsl:apply-templates mode="htmlToDITA"/>
        </codeblock>
    </xsl:template>

    <!--<MadCap:snippetBlock src="../Resources/Snippets/Welcome.flsnp" />-->
    <xsl:template match="*[local-name() = 'snippetBlock']" mode="htmlToDITA">
        <div conref="{replace(@src, '.flsnp', '.dita')}#reusable/reusableComponent"/>
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:function name="funct:getFileNameNoExt" as="xs:string">
        <xsl:param name="urlPath" as="xs:string"/>
        <xsl:variable name="fileName" select="tokenize($urlPath, '/')[last()]"/>
        <xsl:variable name="fileNameNoAnchor" select="tokenize($fileName, '\.')[1]"/>
        <xsl:value-of select="$fileNameNoAnchor"/>
    </xsl:function>

    <xsl:function name="funct:validKeyName" as="xs:string">
        <xsl:param name="keyName" as="xs:string"/>
        <xsl:value-of select="replace($keyName, ' ', '_')"/>
    </xsl:function>

    <xsl:function name="funct:processTimestamp" as="xs:string">
        <xsl:param name="timestamp" as="xs:string"/>
        <xsl:variable name="processed" as="xs:string">
            <xsl:value-of select="replace($timestamp, '-', '')"/>
        </xsl:variable>
        <xsl:variable name="processed" select="replace($processed, ':', '')"/>
        <xsl:variable name="processed" select="replace($processed, '\.(.*?)\+', '+')"/>
        <xsl:value-of select="$processed"/>
    </xsl:function>

    <!-- Translates a file path to a file:// URL. -->
    <xsl:function name="funct:toUrl" as="xs:string">
        <xsl:param name="filepath" as="xs:string"/>
        <xsl:variable name="url" as="xs:string" select="
                if (contains($filepath, '\'))
                then
                    translate($filepath, '\', '/')
                else
                    $filepath
                "/>
        <xsl:variable name="fileUrl" as="xs:string" select="
                if (matches($url, '^[a-zA-Z]:'))
                then concat('file:/', $url)
                else if (starts-with($url, '/'))
                    then concat('file:', $url)
                    else $url
                "/>
        <xsl:variable name="escapedUrl" select="replace($fileUrl, ' ', '%20')"/>
        <xsl:sequence select="$escapedUrl"/>
    </xsl:function>
    
    <xsl:function name="funct:correctURL" as="xs:string">
        <xsl:param name="filepath" as="xs:string"/>
        <xsl:variable name="url" as="xs:string" select="
            if (contains($filepath, '\'))
            then
            translate($filepath, '\', '/')
            else
            $filepath
            "/>
        <xsl:variable name="escapedUrl" select="iri-to-uri($url)"/>
        <xsl:sequence select="$escapedUrl"/>
    </xsl:function>
</xsl:stylesheet>
