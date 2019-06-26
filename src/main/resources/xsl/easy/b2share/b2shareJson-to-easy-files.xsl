<!--

    Copyright (C) 2018 DANS - Data Archiving and Networked Services (info@dans.knaw.nl)

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

-->
<xsl:stylesheet
        xmlns:dcterms="http://purl.org/dc/terms/"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output encoding="UTF-8" indent="yes" method="xml"/>
  <xsl:strip-space elements="*"/>

  <xsl:param name="dvnJson"/>

  <xsl:mode on-no-match="shallow-copy"/>

  <xsl:template name="initialTemplate">
    <xsl:apply-templates select="json-to-xml($dvnJson)"/>
  </xsl:template>
  <!--[@key='typeName' and text()='title']-->
  <xsl:template match="/" xpath-default-namespace="http://www.w3.org/2005/xpath-functions">
    <files>
      <file>
        <xsl:variable name="jsonfilename" select="concat(/map/map[@key='_deposit']/map[@key='pid']/string[@key='value']/.,'.json')"/>
        <xsl:attribute name="filepath">
          <xsl:value-of select="concat('data/Metadata export from B2Share/',$jsonfilename)"/>
        </xsl:attribute>
        <dcterms:title><xsl:value-of select="$jsonfilename"/></dcterms:title>
        <dcterms:format>application/json</dcterms:format>
        <dcterms:accessibleToRights>ANONYMOUS</dcterms:accessibleToRights>
        <dcterms:visibleToRights>ANONYMOUS</dcterms:visibleToRights>
      </file>
      <xsl:for-each select="/map/array[@key='_files']/map">
        <file>
          <xsl:attribute name="filepath">
            <xsl:value-of select="concat('data/',./string[@key='name']/.)"/>
          </xsl:attribute>
          <dcterms:format xsi:type="dcterms:IMT"><xsl:value-of select="./string[@key='mimetype']/."/></dcterms:format>
          <dcterms:title><xsl:value-of select="./string[@key='name']/."/></dcterms:title>
          <xsl:choose>
            <xsl:when test="./boolean[@key='restricted']/. = 'true'">
              <dcterms:accessibleToRights>RESTRICTED_REQUEST</dcterms:accessibleToRights>
            </xsl:when>
            <xsl:otherwise>
              <dcterms:accessibleToRights>ANONYMOUS</dcterms:accessibleToRights>
            </xsl:otherwise>
          </xsl:choose>
          <dcterms:visibleToRights>ANONYMOUS</dcterms:visibleToRights>
        </file>
      </xsl:for-each>
    </files>
  </xsl:template>
</xsl:stylesheet>
