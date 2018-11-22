package nl.knaw.dans.bridge.mappings.xsl;

import net.sf.saxon.s9api.SaxonApiException;
import nl.knaw.dans.bridge.plugin.lib.util.BridgeHelper;
import org.apache.commons.io.FileUtils;
import org.junit.AfterClass;
import org.junit.BeforeClass;
import org.junit.Ignore;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.Mockito;
import org.powermock.core.classloader.annotations.PrepareForTest;
import org.powermock.modules.junit4.PowerMockRunner;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathFactory;
import java.io.File;
import java.io.IOException;
import java.lang.invoke.MethodHandles;
import java.net.URL;
import java.nio.charset.StandardCharsets;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;

import static org.junit.Assert.assertTrue;
import static org.junit.Assert.assertEquals;
import static org.powermock.api.mockito.PowerMockito.mockStatic;
import static org.powermock.api.mockito.PowerMockito.when;


/*
Eko Indarto
 */
@RunWith(PowerMockRunner.class)
@PrepareForTest({BridgeHelper.class})
public class MappingTest {

    private static final Logger LOG = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass());
    final static String initialXsltTemplate = "initialTemplate";
    final static String paramJson = "dvnJson";

    private static URL dataverseJsonMetadataUrl;
    private static final String resultsDir = "src/test/resources/output/results";
    private static final String actualFilenameOfEasyDatasetXml = resultsDir + "/hdl-101204-hkdsa-easy-dataset-result.xml";
    private static final String actualFilenameOfEasyFilesXml = resultsDir + "/hdl-101204-hkdsa-easy-files-result.xml";
    private static final String actualFilenameOfFilesLocationXml = resultsDir + "/hdl-101204-hkdsa-files-location-result.xml";

    private final XPath xPath = XPathFactory.newInstance().newXPath();

    private static final String ENCODING = StandardCharsets.UTF_8.name();

    @BeforeClass
    public static void setUp() throws Exception {
        mockStatic(BridgeHelper.class);
        dataverseJsonMetadataUrl = new File("src/test/resources/json/hdl-101204-hkdsa.json").toURI().toURL();

        cleanupTransformfileResult();
    }

    @Test
    public void transformEasyXsl() throws IOException, SaxonApiException {
        URL  dvnJsonToEasyDatasetXslUrl = new File("src/main/resources/xsl/easy/dataverse/dataverseJson-to-easy-dataset.xsl").toURI().toURL();
        URL dvnJsonToEasyFilesXslUrl = new File("src/main/resources/xsl/easy/dataverse/dataverseJson-to-easy-files.xsl").toURI().toURL();
        URL dvnJsonToSourceFilesLocationXslUrl = new File("src/main/resources/xsl/easy/dataverse/dataverseJson-to-files-location.xsl").toURI().toURL();

        //Given
        File expectedEasyDatasetXmlFile = new File("src/test/resources/output/easy/hdl-101204-hkdsa-easy-dataset-expected.xml");
        when(BridgeHelper.transformJsonToXml(Mockito.anyObject(), Mockito.anyObject(), Mockito.anyObject(), Mockito.anyObject())).thenCallRealMethod();
        //When
        String actualEasyDatasetXml = BridgeHelper.transformJsonToXml(dataverseJsonMetadataUrl, dvnJsonToEasyDatasetXslUrl, initialXsltTemplate, paramJson);
        LOG.info("actualEasyDatasetXml: \n{}", actualEasyDatasetXml);
        //Then
        File actualEasyDatasetXmlFile = new File(actualFilenameOfEasyDatasetXml);
        FileUtils.writeStringToFile(actualEasyDatasetXmlFile, actualEasyDatasetXml, ENCODING);

        // The problem with dataset.xml construction is the date available; <ddm:available> which is set to the current date by the xsl and thus changes every day!
        // This is fixed by putting a placeholder in the expected xml file and replace it with the current dat string.
        // When replacements like this need to be done for more xml elemens we might consider using a templating engine.
        DateFormat df = new SimpleDateFormat("yyyy-MM-dd");
        String currentDateStr = df.format(new Date());
        assertEquals(FileUtils.readFileToString(expectedEasyDatasetXmlFile, ENCODING).replaceAll("\\{\\{ CURRENT_DATE \\}\\}", currentDateStr).trim(),
        FileUtils.readFileToString(actualEasyDatasetXmlFile, ENCODING).trim());

        // Given
        File expectedEasyFilesXmlFile = new File("src/test/resources/output/easy/hdl-101204-hkdsa-easy-files-expected.xml");
        // When
        String actualEasyFilesXml = BridgeHelper.transformJsonToXml(dataverseJsonMetadataUrl, dvnJsonToEasyFilesXslUrl, initialXsltTemplate, paramJson);
        LOG.info("actualEasyFilesXml: \n{}", actualEasyFilesXml);
        // Then
        File actualEasyFilesXmlFile = new File(actualFilenameOfEasyFilesXml);
        FileUtils.writeStringToFile(actualEasyFilesXmlFile, actualEasyFilesXml, ENCODING);
        assertTrue(FileUtils.contentEqualsIgnoreEOL(expectedEasyFilesXmlFile, actualEasyFilesXmlFile, ENCODING));

        // Given
        File expectedFilenameOfFilesLocationXml = new File("src/test/resources/output/easy/hdl-101204-hkdsa-files-location-expected.xml");
        // When
        String actualFilesLocationXml = BridgeHelper.transformJsonToXml(dataverseJsonMetadataUrl, dvnJsonToSourceFilesLocationXslUrl, initialXsltTemplate, paramJson);
        LOG.info("actualFilesLocationXml: \n{}", actualFilesLocationXml);
        // Then
        File actualFilenameOfFilesLocation = new File(actualFilenameOfFilesLocationXml);
        FileUtils.writeStringToFile(actualFilenameOfFilesLocation, actualFilesLocationXml, ENCODING);
        assertTrue(FileUtils.contentEqualsIgnoreEOL(expectedFilenameOfFilesLocationXml, actualFilenameOfFilesLocation, ENCODING));
    }

    @Ignore
    @Test
    public void transformDaraXsl() throws IOException, SaxonApiException {
    }

    @Ignore
    @Test
    public void transformB2ShareXsl() throws IOException, SaxonApiException {
    }

    @AfterClass
    public static void oneTimeTearDown() {
        // one-time cleanup

        // leave results here for inspection after failure
        //cleanupTransformfileResult();
    }

    private static void cleanupTransformfileResult() {
        File actualResultFileOfEasyDatasetXml = new File(actualFilenameOfEasyDatasetXml);
        if (actualResultFileOfEasyDatasetXml.exists())
            actualResultFileOfEasyDatasetXml.delete();
        File actualResultFileOfEasyFilesXml = new File(actualFilenameOfEasyFilesXml);
        if (actualResultFileOfEasyFilesXml.exists())
            actualResultFileOfEasyFilesXml.delete();
        File actualFilenameOfFilesLocation = new File(actualFilenameOfFilesLocationXml);
        if (actualFilenameOfFilesLocation.exists())
            actualFilenameOfFilesLocation.delete();
    }
}
