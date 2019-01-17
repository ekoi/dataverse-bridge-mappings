<xsl:stylesheet
        xmlns:emd="http://easy.dans.knaw.nl/easy/easymetadata/"
        xmlns:dc="http://purl.org/dc/elements/1.1/"
        xmlns:dcterms="http://purl.org/dc/terms/"
        xmlns:ddm="http://easy.dans.knaw.nl/schemas/md/ddm/"
        xmlns:dcx-dai="http://easy.dans.knaw.nl/schemas/dcx/dai/"
        xmlns:mods="http://www.loc.gov/mods/v3"
        xmlns:dcx-gml="http://easy.dans.knaw.nl/schemas/dcx/gml/"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns:id-type="http://easy.dans.knaw.nl/schemas/vocab/identifier-type/"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xpath-default-namespace="http://www.w3.org/2005/xpath-functions"
        version="3.0">
  <xsl:output encoding="UTF-8" indent="yes" method="xml"/>
  <xsl:strip-space elements="*"/>

  <xsl:param name="dvnJson"/>

  <xsl:mode on-no-match="shallow-copy"/>

  <xsl:template name="initialTemplate">
    <xsl:apply-templates select="json-to-xml($dvnJson)"/>
  </xsl:template>
  <!--[@key='typeName' and text()='title']-->
    <xsl:template match="/">
      <ddm:DDM>
        <xsl:call-template name="profile"/>
        <xsl:call-template name="dcmiMetadata"/>
      </ddm:DDM>
    </xsl:template>
  <xsl:template name="profile">
    <ddm:profile>
      <dc:title>
        <xsl:value-of select="//array[@key='fields']/map/string[@key='typeName' and text()='title']/following-sibling::string[@key='value']/."/>
      </dc:title>
      <xsl:if test="//array[@key='fields']/map/string[@key='typeName' and text()='subtitle']/following-sibling::string[@key='value']/.">
        <dcterms:alternative>
          <xsl:value-of select="concat(//array[@key='fields']/map/string[@key='typeName' and text()='title']/following-sibling::string[@key='value']/., ' - ', //array[@key='fields']/map/string[@key='typeName' and text()='subtitle']/following-sibling::string[@key='value']/.)"/>
        </dcterms:alternative>
      </xsl:if>
      <dcterms:description>
        <xsl:value-of select="//map[@key='dsDescriptionValue']/string[@key='typeName' and text()='dsDescriptionValue']/following-sibling::string[@key='value']/."/>
      </dcterms:description>
      <xsl:for-each select="//map/array[@key='value']/map/map[@key='authorName']">
        <xsl:variable name="intial" select="substring-after(./string[@key='typeName' and text()='authorName']/following-sibling::string[@key='value']/., ', ')"/>
        <xsl:variable name="surname" select="substring-before(./string[@key='typeName' and text()='authorName']/following-sibling::string[@key='value']/., ', ')"/>
        <dcx-dai:creatorDetails>
          <dcx-dai:author>
            <!-- <dcx-dai:titles></dcx-dai:titles> -->
            <dcx-dai:initials>
              <!--<xsl:value-of select="substring($intial, 1, 1)"/>-->
              <xsl:value-of select="$intial"/>
            </dcx-dai:initials>
            <dcx-dai:insertions/>
            <dcx-dai:surname>
              <xsl:value-of select="$surname"/>
            </dcx-dai:surname>
            <dcx-dai:organization>
              <dcx-dai:name xml:lang="en">
                <xsl:value-of select="./parent::*//map[@key='authorAffiliation']/string[@key='value']/."/>
              </dcx-dai:name>
            </dcx-dai:organization>
          </dcx-dai:author>
        </dcx-dai:creatorDetails>
      </xsl:for-each>
      <ddm:created>
        <xsl:value-of select="/map/string[@key='publicationDate']/."/>
        <!--<xsl:value-of select="format-dateTime(/map/map[@key='datasetVersion']/string[@key='releaseTime']/.,'[Y0001]-[M01]-[D01]')"/>-->
      </ddm:created>
      <!-- current date instead, according to document -->
      <ddm:available>
        <xsl:value-of select="format-dateTime(current-dateTime(), '[Y0001]-[M01]-[D01]')"/>
      </ddm:available>
      <xsl:for-each select="/map/map/map[@key='metadataBlocks']/map[@key='citation']/array[@key='fields']/map/string[@key='typeName' and text()='subject']/following-sibling::array[@key='value']/string/.">

        <!--<ddm:audience>-->
        <!--<xsl:value-of select="."/>-->
        <!--</ddm:audience>-->
        <xsl:variable name="audience">
          <xsl:call-template name="audiencefromkeyword">
            <xsl:with-param name="val" select="."/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:if test="$audience != ''">
          <ddm:audience>
            <xsl:value-of select="$audience"/>
          </ddm:audience>
        </xsl:if>
      </xsl:for-each>
      <xsl:choose>
        <xsl:when test="count(/map/map/array/map[boolean='true']) = 0">
        	<ddm:accessRights>OPEN_ACCESS</ddm:accessRights>
	</xsl:when>
        <xsl:otherwise>
         <ddm:accessRights>REQUEST_PERMISSION</ddm:accessRights>
        </xsl:otherwise>
      </xsl:choose>

      <!--<xsl:for-each select="//map[@key='datasetVersion']/array[@key='files']/map">-->
        <!--<xsl:choose>-->
          <!--<xsl:when test="./boolean[@key='restricted']/. = 'true'">-->
            <!--<dcterms:accessibleToRights>RESTRICTED_REQUEST</dcterms:accessibleToRights>-->
          <!--</xsl:when>-->
          <!--<xsl:otherwise>-->
            <!--<dcterms:accessibleToRights>OPEN_ACCESS</dcterms:accessibleToRights>-->
          <!--</xsl:otherwise>-->
        <!--</xsl:choose>-->
      <!--</xsl:for-each>-->

    </ddm:profile>
  </xsl:template>

  <xsl:template name="dcmiMetadata">
    <ddm:dcmiMetadata>
      <xsl:for-each select="//map[@key='datasetContactName']">
        <dcx-dai:contributorDetails>
          <dcx-dai:author>
            <dcx-dai:initials><xsl:value-of select="substring-after(./string[@key='value']/.,', ')"/></dcx-dai:initials>
            <dcx-dai:surname><xsl:value-of select="substring-before(./string[@key='value']/.,', ')"/></dcx-dai:surname>
            <dcx-dai:role>ContactPerson</dcx-dai:role>
          </dcx-dai:author>
        </dcx-dai:contributorDetails>
      </xsl:for-each>
      <xsl:for-each select="/map/map/map[@key='metadataBlocks']/map[@key='citation']/array[@key='fields']/map/string[@key='typeName' and text()='language']/following-sibling::array[@key='value']/string/.">
        <dc:language>
          <xsl:value-of select="."/>
        </dc:language>
      </xsl:for-each>
      <xsl:call-template name="opensourcelicense">
        <xsl:with-param name="lic" select="normalize-space(/map/map[@key='datasetVersion']/string[@key='termsOfUse']/.)"/>
      </xsl:call-template>
      <dcterms:rightsHolder/>
      <!-- list all keywords, even if allreay mapped to audience, because we have human readable Datavese specific text -->
      <xsl:for-each select="/map/map/map[@key='metadataBlocks']/map[@key='citation']/array[@key='fields']/map/string[@key='typeName' and text()='keyword']/following-sibling::array[@key='value']/map/.">
        <!--<xsl:if test="not(empty(./map[@key='keywordVocabularyURI']/string[@key='value']/.) or empty(./map[@key='keywordVocabulary']/string[@key='value']/.))">-->
          <ddm:subject>
            <!--<xsl:attribute name="xml:lang">en</xsl:attribute>-->
            <xsl:attribute name="valueURI"><xsl:value-of select="./map[@key='keywordVocabularyURI']/string[@key='value']/."/></xsl:attribute>
            <xsl:attribute name="subjectScheme"><xsl:value-of select="./map[@key='keywordVocabulary']/string[@key='value']/."/></xsl:attribute>
            <xsl:attribute name="schemeURI"><xsl:value-of select="./map[@key='keywordVocabularyURI']/string[@key='value']/."/></xsl:attribute><xsl:value-of select="./map[@key='keywordValue']/string[@key='value']/."/></ddm:subject>
        <!--</xsl:if>-->
      </xsl:for-each>

      <!-- see Laura email d.d. 19 Nov 2018 -->
      <!--<ddm:additional-xml>-->
      <!--<mods:recordInfo>-->
      <!--<mods:recordOrigin><xsl:value-of select="/map/string[@key='publisher']/."/></mods:recordOrigin>-->
      <!--</mods:recordInfo>-->
      <!--</ddm:additional-xml>-->

      <dc:type xsi:type="dcterms:DCMIType">Dataset</dc:type>

      <xsl:for-each select="/map/map/map[@key='metadataBlocks']/map[@key='citation']/array[@key='fields']/map/string[@key='typeName' and text()='relatedMaterial']/following-sibling::array[@key='value']/string/.">
        <dc:relation><xsl:value-of select="."/></dc:relation>
      </xsl:for-each>
      <xsl:for-each select="/map/map/map[@key='metadataBlocks']/map[@key='citation']/array[@key='fields']/map/string[@key='typeName' and text()='relatedDatasets']/following-sibling::array[@key='value']/string/.">
        <dc:relation><xsl:value-of select="."/></dc:relation>
      </xsl:for-each>
      <xsl:for-each select="/map/map/map[@key='metadataBlocks']/map[@key='citation']/array[@key='fields']/map/string[@key='typeName' and text()='otherReferences']/following-sibling::array[@key='value']/string/.">
        <dc:relation><xsl:value-of select="."/></dc:relation>
      </xsl:for-each>
      <xsl:for-each select="/map/map/map[@key='metadataBlocks']/map[@key='citation']/array[@key='fields']/map/string[@key='typeName' and text()='dataSources']/following-sibling::array[@key='value']/string/.">
        <dc:source><xsl:value-of select="."/></dc:source>
      </xsl:for-each>
      <dc:source><xsl:value-of select="/map/map/map[@key='metadataBlocks']/map[@key='citation']/array[@key='fields']/map/string[@key='typeName' and text()='originOfSources']/following-sibling::string[@key='value']/."/></dc:source>


      <ddm:isFormatOf>
        <xsl:attribute name="href"><xsl:value-of select="/map/string[@key='persistentUrl']/."/> </xsl:attribute>
        <xsl:value-of select="concat(/map/string[@key='protocol']/.,':',/map/string[@key='authority']/.,'/',/map/string[@key='identifier']/.)"/>
      </ddm:isFormatOf>

      <xsl:if test="/map/map/map[@key='metadataBlocks']/map[@key='citation']/array[@key='fields']/map/array/map/map[@key='publicationCitation']">
        <ddm:isReferencedBy>
          <xsl:value-of select="/map/map/map[@key='metadataBlocks']/map[@key='citation']/array[@key='fields']/map/array/map/map[@key='publicationCitation']/string[@key='value']/."/>
        </ddm:isReferencedBy>
      </xsl:if>
      <!--Geospatial-->
      <!--Country-->
      <dcterms:spatial>
        <xsl:value-of select="/map/map/map[@key='metadataBlocks']/map[@key='geospatial']/array/map/array[@key='value']/map/map[@key='country']/string[@key='value']/."/>
      </dcterms:spatial>
      <!--State-->
      <dcterms:spatial>
        <xsl:value-of select="/map/map/map[@key='metadataBlocks']/map[@key='geospatial']/array/map/array[@key='value']/map/map[@key='state']/string[@key='value']/."/>
      </dcterms:spatial>
      <!--City-->
      <dcterms:spatial>
        <xsl:value-of select="/map/map/map[@key='metadataBlocks']/map[@key='geospatial']/array/map/array[@key='value']/map/map[@key='city']/string[@key='value']/."/>
      </dcterms:spatial>
      <!--Other-->
      <dcterms:spatial>
        <xsl:value-of select="/map/map/map[@key='metadataBlocks']/map[@key='geospatial']/array/map/array[@key='value']/map/map[@key='otherGeographicCoverage']/string[@key='value']/."/>
      </dcterms:spatial>

      <xsl:if test="/map/map/map[@key='metadataBlocks']/map[@key='geospatial']/array/map/string[@key='typeName' and text()='geographicBoundingBox']/following-sibling::array[@key='value']/map/.">
        <dcx-gml:spatial>
          <boundedBy xmlns="http://www.opengis.net/gml">
            <Envelope srsName="http://www.opengis.net/def/crs/EPSG/0/28992">
              <lowerCorner><xsl:value-of select="concat(//map[@key='eastLongitude']/string[@key='value']/., ' ',//map[@key='southLongitude']/string[@key='value']/.)"/></lowerCorner>
              <upperCorner><xsl:value-of select="concat(//map[@key='westLongitude']/string[@key='value']/., ' ',//map[@key='northLongitude']/string[@key='value']/.)"/></upperCorner>
            </Envelope>
          </boundedBy>
        </dcx-gml:spatial>
      </xsl:if>

    </ddm:dcmiMetadata>
  </xsl:template>
  <!-- Mapping from the Dataverse keywords to the Narcis Discipline types (https://easy.dans.knaw.nl/schemas/vocab/2015/narcis-type.xsd) -->
  <xsl:template name="audiencefromkeyword">
    <xsl:param name="val"/>
    <!-- make our own map, it's small -->
    <xsl:choose>
      <xsl:when test="$val = 'Agricultural Sciences'">
        <xsl:value-of select="'D18000'"/>
      </xsl:when>
      <xsl:when test="$val = 'Law'">
        <xsl:value-of select="'D40000'"/>
      </xsl:when>
      <xsl:when test="$val = 'Social Sciences'">
        <xsl:value-of select="'D60000'"/>
      </xsl:when>
      <xsl:when test="$val = 'Arts and Humanities'">
        <xsl:value-of select="'D30000'"/>
      </xsl:when>
      <xsl:when test="$val = 'Astronomy and Astrophysics'">
        <xsl:value-of select="'D17000'"/>
      </xsl:when>
      <xsl:when test="$val = 'Business and Management'">
        <xsl:value-of select="'D70000'"/>
      </xsl:when>
      <xsl:when test="$val = 'Chemistry'">
        <xsl:value-of select="'D13000'"/>
      </xsl:when>
      <xsl:when test="$val = 'Computer and Information Science'">
        <xsl:value-of select="'D16000'"/>
      </xsl:when>
      <xsl:when test="$val = 'Earth and Environmental Sciences'">
        <xsl:value-of select="'D15000'"/>
      </xsl:when>
      <xsl:when test="$val = 'Engineering'">
        <xsl:value-of select="'D14400'"/>
      </xsl:when>
      <xsl:when test="$val = 'Mathematical Sciences'">
        <xsl:value-of select="'D11000'"/>
      </xsl:when>
      <xsl:when test="$val = 'Medicine, Health and Life Sciences'">
        <xsl:value-of select="'D20000'"/>
      </xsl:when>
      <xsl:when test="$val = 'Physics'">
        <xsl:value-of select="'D12000'"/>
      </xsl:when>
      <xsl:when test="$val = 'Other'">
        <xsl:value-of select="'E10000'"/>
      </xsl:when>
      <xsl:otherwise>
        <!-- Don't do the default mapping to E10000, otherwise we cannot detect that nothing was found -->
        <xsl:value-of select="''"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template name="opensourcelicense">
    <xsl:param name="lic"/>
    <xsl:choose>
      <xsl:when test="($lic = 'http://creativecommons.org/publicdomain/zero/1.0') or
                      ($lic = 'http://creativecommons.org/licenses/by/4.0') or
                      ($lic = 'http://creativecommons.org/licenses/by-nc-sa/3.0') or
                      ($lic = 'http://creativecommons.org/licenses/by-nc/3.0') or
                      ($lic = 'http://opensource.org/licenses/MIT') or
                      ($lic = 'http://www.apache.org/licenses/LICENSE-2.0') or
                      ($lic = 'http://opensource.org/licenses/BSD-3-Clause') or
                      ($lic = 'http://opensource.org/licenses/BSD-2-Clause') or
                      ($lic = 'http://www.gnu.org/licenses/gpl-3.0.en.html') or
                      ($lic = 'http://www.ohwr.org/attachments/2388/cern_ohl_v_1_2.txt') or
                      ($lic = 'http://www.ohwr.org/attachments/735/CERNOHLv1_1.txt') or
                      ($lic = 'http://www.tapr.org/TAPR_Open_Hardware_License_v1.0.txt')">
        <dcterms:license xsi:type="dcterms:URI"><xsl:value-of select="$lic"/></dcterms:license>
      </xsl:when>
      <xsl:otherwise>
        <dcterms:license><xsl:value-of select="/map/map[@key='datasetVersion']/string[@key='license']/."/></dcterms:license>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
