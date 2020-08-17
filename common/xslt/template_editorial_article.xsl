<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xdoc="http://www.pnp-software.com/XSLTdoc"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:dhq="http://www.digitalhumanities.org/ns/dhq"
    xmlns:m="http://www.w3.org/1998/Math/MathML"
    exclude-result-prefixes="tei dhq xdoc" version="1.0">
    
    <xsl:import href="sidenavigation.xsl"/>
    <xsl:import href="topnavigation.xsl"/>
    <xsl:import href="footer.xsl"/>
    <xsl:import href="head.xsl"/>
    <xsl:import href="dhq2html.xsl"/>
    <xsl:output method="xml" omit-xml-declaration="yes" indent="yes" encoding="UTF-8"/>
    
    <xdoc:doc type="stylesheet">
        <xdoc:author>John A. Walsh</xdoc:author>
        <xdoc:copyright>Copyright 2006 John A. Walsh</xdoc:copyright>
        <xdoc:short>XSLT stylesheet to transform DHQauthor documents to XHTML.</xdoc:short>
    </xdoc:doc>
    <!--    <xsl:param name="source" select="''"/>-->
    <xsl:param name="context"/>
    <xsl:param name="fpath"/>
    <xsl:template match="tei:TEI">
        <!-- base url to which vol issue id to be attached -->
        
        <html>
            <!-- code to retrieve document title from the html file and pass it to the template -->
            <xsl:call-template name="head">
                <xsl:with-param name="title" select="tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title"/>
            </xsl:call-template>
            
            <body>
                <!-- Call different templates to put the banner, footer, top and side navigation elements -->
                <!--  <xsl:call-template name="banner"/>-->
                <xsl:call-template name="topnavigation"/>
                <div id="main">
                    <div id="leftsidebar">
                        <xsl:call-template name="sidenavigation">
                            <xsl:with-param name="session" select="'true'"/>
                        </xsl:call-template>
                        <!-- moved tapor toolbar to the article level toolbar in dhq2html xslt -->
                        <!--                        <xsl:call-template name="taportool"/> -->
                    </div>
                    <div id="mainContent">
                        <xsl:call-template name="sitetitle"/>
                        
                        <!-- Rest of the document/article is coverd in this template - this is a call to dhq2html.xsl -->
                        <xsl:call-template name="article_main_body"/> 
                        <!-- Use the URL generated to pass to the footer -->
                        <xsl:call-template name="footer">
                            <xsl:with-param name="docurl" select="$fpath"/>
                        </xsl:call-template>
                    </div>
                </div>
                <xsl:call-template name="customBody"/>
            </body>
        </html>
    </xsl:template>
    
    <!-- customBody template (below) may be overridden in article-specific XSLT (in articles/XXXXXX/resources/xslt/XXXXXX.xsl) to include additional stuff at end of the HTML <body>. See 000151. -->
    <xsl:template name="customBody"/>
    
    <xsl:template match="tei:teiHeader/tei:fileDesc/tei:titleStmt/dhq:authorInfo">
        <!-- Using lower-case of author's last name + first initial to sort [CRB] -->
        <xsl:variable name="lower">abcdefghijklmnopqrstuvwxyz</xsl:variable>
        <xsl:variable name="upper">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>
        <xsl:variable name="bios">
            <xsl:value-of select="translate(concat(translate(dhq:author_name/dhq:family,' ',''),'_',substring(normalize-space(dhq:author_name),1,1)),$upper,$lower)"/>
        </xsl:variable>
        <div class="author">
            <a rel="external">
                <xsl:attribute name="href">
                    <xsl:value-of select="concat('/',$context,'/editorial/bios.html','#',$bios)"/>
                </xsl:attribute>
                <xsl:apply-templates select="dhq:author_name"/>
            </a>
            <xsl:if test="normalize-space(child::dhq:affiliation)">
                <xsl:apply-templates select="tei:email" mode="author"/>
                <xsl:text>, </xsl:text>
            </xsl:if>
            <xsl:apply-templates select="dhq:affiliation"/>
        </div>
    </xsl:template>
    
    <xsl:template name="pubInfo">
        <div id="pubInfo">
            <xsl:text>Editorial</xsl:text><br />
        </div>
    </xsl:template>
    
    <xsl:template name="toolbar">
        <xsl:param name="vol_no_zeroes"><xsl:call-template name="get-vol">
            <xsl:with-param name="vol"><xsl:value-of select="$vol"/></xsl:with-param></xsl:call-template>
        </xsl:param>
        <div class="toolbar">
            <a>
                <xsl:attribute name="href">
                    <xsl:value-of select="concat('/',$context,'/editorial/index.html')"/>
                </xsl:attribute>
                <xsl:text>Editorial</xsl:text>
            </a>
            &#x00a0;|&#x00a0;
            <a>
                <xsl:attribute name="href">
                    <xsl:value-of select="concat('/',$context,'/editorial/',$id,'/',$id,'.xml')"/>
                </xsl:attribute>
                <xsl:text>XML</xsl:text>
            </a>
            |&#x00a0;
            <a href="#" onclick="javascript:window.print();"
                title="Click for print friendly version">Print Article</a>
        </div> 
        <!--        <div> 
            <xsl:call-template name="taportool"/>
            </div> -->
    </xsl:template>
    
    <xsl:template name="toolbar_with_tapor">
        <div class="toolbar">
            <form id="taporware" action="get">
                <!-- added <p></p> to surrond form content to validate [CRB] -->
                <p>
                    <a>
                        <xsl:attribute name="href">
                            <xsl:value-of select="concat('/',$context,'/editorial/index.html')"/>
                        </xsl:attribute>
                        <xsl:text>Editorial</xsl:text>
                    </a>
                    &#x00a0;|&#x00a0;
                    <a>
                        <xsl:attribute name="href">
                            <xsl:value-of select="concat('/',$context,'/editorial/',$id,'/',$id,'.xml')"/>
                        </xsl:attribute>
                        <xsl:text>XML</xsl:text>
                    </a>
                    |&#x00a0;
                    <a href="#" onclick="javascript:window.print();"
                        title="Click for print friendly version">Print Article</a>&#x00a0;|&#x00a0;
                    <select name="taportools" onchange="gototaporware()">
                        <option>Taporware Tools</option>
                        <option value="listword">List Words</option>
                        <option value="findtext">Find Text</option>
                        <option value="colloc">Collocation</option>
                    </select>
                </p>
            </form>
            <!--            <xsl:call-template name="taportool"/> -->
        </div>
    </xsl:template>
    
</xsl:stylesheet>
