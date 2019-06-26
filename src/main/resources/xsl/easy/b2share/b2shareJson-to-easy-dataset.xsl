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
        xmlns:emd="http://easy.dans.knaw.nl/easy/easymetadata/"
        xmlns:dc="http://purl.org/dc/elements/1.1/"
        xmlns:dcterms="http://purl.org/dc/terms/"
        xmlns:ddm="http://easy.dans.knaw.nl/schemas/md/ddm/"
        xmlns:dcx-dai="http://easy.dans.knaw.nl/schemas/dcx/dai/"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns:id-type="http://easy.dans.knaw.nl/schemas/vocab/identifier-type/"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        version="3.0">
  <xsl:output encoding="UTF-8" indent="yes" method="xml"/>
  <xsl:strip-space elements="*"/>

  <xsl:param name="dvnJson"/>

  <xsl:mode on-no-match="shallow-copy"/>

  <xsl:template name="initialTemplate">
    <xsl:apply-templates select="json-to-xml($dvnJson)"/>
  </xsl:template>
  <!--[@key='typeName' and text()='title']-->
  <xsl:template match="/" xpath-default-namespace="http://www.w3.org/2005/xpath-functions">
    <ddm:DDM>
      <ddm:profile>
        <dc:title>
          <xsl:value-of select="/map/array[@key='titles']/map/string[@key='title']/."/>
        </dc:title>
        <dcterms:description>
          <xsl:value-of select="/map/array[@key='descriptions']/map/string[@key='description']/."/>
        </dcterms:description>
        <!--<xsl:for-each select="/map/map[@key='metadata']/array[@key='creators']/.">-->
        <dcx-dai:creatorDetails>
          <dcx-dai:author>
            <dcx-dai:initials>E</dcx-dai:initials>
            <dcx-dai:insertions/>
            <dcx-dai:surname>Indarto</dcx-dai:surname>
            <dcx-dai:organization>
              <dcx-dai:name xml:lang="en"/>
            </dcx-dai:organization>
          </dcx-dai:author>
        </dcx-dai:creatorDetails>
        <!--</xsl:for-each>-->
        <ddm:created>
          <xsl:value-of select="format-dateTime(/map/map[@key='_oai']/string[@key='updated']/.,'[Y0001]-[M01]-[D01]')"/>
        </ddm:created>
        <!-- current date instead, according to document -->
        <ddm:available>
          <xsl:value-of select="format-dateTime(current-dateTime(), '[Y0001]-[M01]-[D01]')"/>
        </ddm:available>
        <ddm:audience>D60000</ddm:audience>
        <ddm:accessRights>OPEN_ACCESS</ddm:accessRights>
      </ddm:profile>
    </ddm:DDM>
  </xsl:template>


</xsl:stylesheet>
