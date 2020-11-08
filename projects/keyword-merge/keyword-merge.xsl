<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="3.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  exclude-result-prefixes="xs map"
  
  xmlns="http://www.tei-c.org/ns/1.0"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  xmlns:dhq="http://www.digitalhumanities.org/ns/dhq">

  <!--             
next up

x pull down git fork
o wire up with paths
  
  -->
  <xsl:variable name="lookup-file" as="xs:string">source/Revised%2520Article%2520list.xhtml</xsl:variable>
  
  <xsl:variable name="lookup" select="document($lookup-file)"/>
  
  <xsl:variable name="skip-article" as="element()*">
    <no>000492</no>
    <no>000523</no>
  </xsl:variable>

  <xsl:variable name="article-keywords" as="map(xs:string, xs:string*)">
    <xsl:map>
      <!-- keywords all (and only) start with '#'; articles are given as the first cells in their rows -->
      <!-- so we build a map keying article numbers to their keywords -->
      <!--<xsl:message expand-text="true">{ $lookup/document-uri(/) } : { count($lookup/*)}</xsl:message>-->
      <xsl:for-each-group select="$lookup//*:td[starts-with(.,'#')]/../*:td[1][true() or not(.=$skip-article)]" group-by=".">
        <xsl:map-entry key="current-grouping-key() ! string(.)"
                       select="current-group()/../*:td[starts-with(.,'#')] ! string(.)"/>
      </xsl:for-each-group>
    </xsl:map>
  </xsl:variable>

  <xsl:template match="/" name="xsl:initial-template">
    <xsl:iterate select="map:keys($article-keywords)[matches(.,'(2|4|6|7)5$')]" expand-text="true">
      <xsl:call-template name="copy-with-keywords">
        <xsl:with-param name="read-from">../../articles/{.}/{.}.xml</xsl:with-param>
        <xsl:with-param name="write-to">merge/articles/{.}/{.}.xml</xsl:with-param>
        <xsl:with-param name="keywords" tunnel="true" select="$article-keywords(.)"/>
      </xsl:call-template>
    </xsl:iterate>
  </xsl:template>

  <xsl:output name="clean" indent="no"/>
  
  <xsl:template name="copy-with-keywords">
    <xsl:param name="read-from" as="xs:string" required="true"/>
    <xsl:param name="write-to"  as="xs:string" required="true"/>
    <xsl:param name="keywords" tunnel="true" required="true" as="xs:string*"/>
    <xsl:message expand-text="true">WRITING { $write-to }: KEYWORDS { $keywords => string-join(', ') }</xsl:message>      
    <xsl:result-document href="{$write-to}" format="clean">
       <xsl:apply-templates mode="merge-keywords" select="document($read-from)"/>
    </xsl:result-document>
  </xsl:template>
  
  <xsl:mode name="merge-keywords" on-no-match="shallow-copy"/>

  <!-- These are provided as schema defaults so we drop them. -->
  <xsl:template match="@part[.='N'] | @status[.='draft'] | @ordered[.='true'] | @scheme[.='TEI']" mode="merge-keywords"/>
  
  <xsl:template match="teiHeader[empty(revisionDesc)]" mode="merge-keywords">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates mode="merge-keywords"/>
      <revisionDesc>
        <xsl:call-template name="mark-revision"/>
      </revisionDesc>
    </xsl:copy>
  </xsl:template>

  <xsl:template mode="merge-keywords" match="revisionDesc">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <!-- indent -->
      <xsl:copy-of select="text()[1]"/>
      <xsl:call-template name="mark-revision"/>
      <xsl:apply-templates mode="merge-keywords"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template mode="merge-keywords" match="profileDesc[empty(textClass)]">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates mode="merge-keywords"/>
      <!--<xsl:copy-of select="text()[1]"/>-->
      <xsl:text>   </xsl:text>
      <textClass>
        <xsl:call-template name="insert-keywords">
          <xsl:with-param name="indent" select="text()[1]"/>
        </xsl:call-template>
      </textClass>
      <xsl:copy-of select="text()[1]"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template mode="merge-keywords" match="textClass">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <!-- indent -->
      <xsl:call-template name="insert-keywords">
        <xsl:with-param name="indent" select="text()[1]"/>
      </xsl:call-template>
      <xsl:apply-templates mode="merge-keywords"/>
    </xsl:copy>
  </xsl:template>
  
  <!--  dropping empty template keywords elements -->
  <xsl:template mode="merge-keywords" match="keywords[@scheme='#dhq_keywords'][not(matches(string(.),'\S'))]"/>
  
  <xsl:template name="insert-keywords">
    <xsl:param name="keywords" tunnel="true" required="true" as="xs:string*"/>
    <xsl:param name="indent" as="xs:string"/>
    <xsl:sequence select="$indent || '   '"/>
    <keywords scheme="#dhq_keywords">
      <xsl:sequence select="$indent || '      '"/>
      <list type="simple">
        <xsl:iterate select="$keywords" expand-text="true">
          <xsl:sequence select="$indent || '         '"/>
          <item>{.}</item>
          <xsl:if test="position() eq last()">
            <xsl:sequence select="$indent || '      '"/>
          </xsl:if>
        </xsl:iterate>
      </list>
      <xsl:sequence select="$indent || '   '"/>
    </keywords>
  </xsl:template>

  <xsl:template name="mark-revision">
    <change who="wap" when="{ current-date() => string() => replace('\-[^\-]+$','') }">Merged keywords</change>
  </xsl:template>
</xsl:stylesheet>