package org.sakuli.integration;

import org.sakuli.starter.SakuliStarter;
import org.testng.annotations.Test;

/**
 * Created by schneckto on 04.05.2015.
 */
public class JavaScriptIntegrationTest {

    @Test
    public void testMnet() throws Exception {
        SakuliStarter.runTestSuite("test-suites/mnet-website-test-suite", "target/classes/org/sakuli/common", null, "sakuli_inst/sahi");

    }
}
