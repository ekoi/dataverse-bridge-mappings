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
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
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
      <xsl:variable name="b2shareApiBaseUrl">
        <xsl:value-of select="'http://devb2share.dans.knaw.nl:5000/api/archive'"/>
      </xsl:variable>
      <file restricted="false" size="10122004">
        <xsl:attribute name="url">
          <xsl:value-of select="concat($b2shareApiBaseUrl, '/?r=', /map/map[@key='_deposit']/string[@key='id']/.)"/>
        </xsl:attribute>
        <xsl:variable name="jsonfilename" select="concat(/map/map[@key='_deposit']/map[@key='pid']/string[@key='value']/.,'.json')"/>
        <xsl:value-of select="concat('Metadata export from B2Share/',$jsonfilename)"/>
      </file>
      <xsl:for-each select="/map/array[@key='_files']/map">
        <file>
          <xsl:variable name="restrictedVal" select="'false'"/>
          <xsl:variable name="urlVal" select="./string[@key='file-location']/."/>
          <xsl:attribute name="restricted">
            <xsl:value-of select="$restrictedVal"/>
          </xsl:attribute>
          <xsl:attribute name="size">
            <xsl:value-of select="./number[@key='size']/."/>
          </xsl:attribute>
          <xsl:attribute name="url">
            <xsl:choose>
              <xsl:when test="$restrictedVal = 'true'">
                <xsl:value-of select="concat($urlVal, '?key=API-TOKEN')"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="replace($urlVal, ' ', '%20')"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>

          <xsl:value-of select="./string[@key='key']/."/>
        </file>
      </xsl:for-each>
    </files>
  </xsl:template>


</xsl:stylesheet>
