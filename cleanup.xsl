<?xml version="1.0" encoding="UTF-8"?>
<!--
  Purpose:
    Filter a DocBook document to list unknown words find by hunspell

  Output:
    DocBook5 XML, but some nodes are supressed which are NOT relevant for spell checking:
    * comments and processing instructions
    * Block elements like screen, programlisting etc.
    * Inline elements like filename, code, literal etc.

  Example:
    To get a list of unknown words, run:

    xsltproc -xinclude cleanup.xsl FILE | hunspell -H -i utf-8 -d en_US,en_US-suse-doc -l

  Author:     Thomas Schraitle, 2022

-->
<xsl:stylesheet version="1.0"
  xmlns:d="http://docbook.org/ns/docbook"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output method="xml"/>
  <!--<xsl:strip-space elements="*"/>
  <xsl:preserve-space elements="d:para"/>-->
  
  <xsl:template match="node() | @*" name="copy">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="comment()"/>
  <xsl:template match="processing-instruction()"/>

  <!-- Block elements -->
  <!-- The following elements are not needed -->
  <xsl:template match="d:classsynopsis|d:destructorsynopsis|d:cmdsynopsis|d:constructorsynopsis|d:funsynopsis
                       |d:fieldsynopsis
                       |d:informalequation
                       |d:methodsynopsis
                       |d:production|d:programlisting|d:programlistingco
                       |d:refsynopsisdiv
                       |d:screen|d:screenco
                       "/>

  <!-- Inline Elements -->
  <xsl:template match="d:abbrev|d:accel|d:acronym|d:address|d:affiliation|d:alt|d:anchor
                       |d:arc|d:area|d:areaset|d:areaspec|d:arg|d:artpagenums|d:audiodata|d:authorinitials
                       |d:classname|d:code|d:command|d:computeroutput
                       |d:database
                       |d:errorcode|d:errorname|d:errortext|d:errortype|d:exceptionname|d:extendedlink
                       |d:fax|d:funcdef|d:funcparams|d:funcprototype|d:filename
                       |d:initializer|d:inlineequation|d:interfacename|d:keycode|d:keycombo|d:keysym
                       |d:literal
                       |d:mathphrase
                       |d:option
                       |d:phone|d:pob|d:postcode
                       |d:remark
                       "/>

</xsl:stylesheet>