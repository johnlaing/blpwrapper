import junit.framework.*;
import java.util.regex.*;
import org.findata.blpwrapper.*;

public class ReferenceDataResultTest extends TestCase {
  private Connection conn;

  public void setUp() throws Exception{
    conn = new Connection();
    conn.connect();
  }

  public void tearDown() throws Exception{
    conn.close();
  }

  public void testLowerCase() throws Exception {
    String[] securities = {"RYA ID Equity"};
    String[] fields = {"name"};

    ReferenceDataResult result = (ReferenceDataResult)conn.blp(securities, fields);
    assertEquals("name", result.getColumnNames()[0]);
  }

  public void testReturnNullForInapplicableFields() throws Exception {
    String[] securities = {"CDG ID Equity", "BKIR ID Equity"};
    String[] fields = {"DVD_PAYOUT_RATIO", "PX_LAST"};

    ReferenceDataResult result = (ReferenceDataResult)conn.blp(securities, fields);
    String[][] data = result.getData();

    assertEquals(null, data[0][0]);
  }


  public void testThrowsErrorForBulkDataRequest() throws Exception {
    String[] securities = {"BKIR ID Equity"};
    String[] fields = {"DVD_HIST"};

    try {
      conn.blp(securities, fields);
      fail("Should have raised an error");
    } catch (WrapperException e) {
      assertEquals("reference data request cannot handle SEQUENCE data in field DVD_HIST", e.getMessage());
    }
  }

  public void testRaisesErrorOnInvalidSecurity() throws Exception {
    String[] securities = {"XXJIOJFDIOSJ US Equity"};
    String[] fields = {"NAME"};

    try {
      conn.blp(securities, fields);
      fail("Should have raised an error");
    } catch (WrapperException e) {
      assertEquals("invalid security XXJIOJFDIOSJ US Equity", e.getMessage());
    }
  }

  public void testRaisesErrorOnInvalidField() throws Exception {
    String[] securities = {"BKIR ID Equity"};
    String[] fields = {"JIODJOIADFSJFOI"};

    try {
      conn.blp(securities, fields);
      fail("Should have raised an error");
    } catch (WrapperException e) {
      assertEquals("invalid field JIODJOIADFSJFOI", e.getMessage());
    }
  }

  public void testRaisesErrorOnMultipleInvalidFields() throws Exception {
    String[] securities = {"BKIR ID Equity"};
    String[] fields = {"XXX1", "XXX2"};

    try {
      conn.blp(securities, fields);
      fail("Should have raised an error");
    } catch (WrapperException e) {
      assertEquals("invalid field XXX1", e.getMessage());
    }
  }

  public void testValidRequest() throws Exception {
    String[] securities = {"RYA ID Equity", "OCN US Equity"};
    String[] fields = {"NAME", "BID", "LOW_DT_52WEEK"};

    ReferenceDataResult result = (ReferenceDataResult)conn.blp(securities, fields);
  }

  public void testValidRequestWithOverrides() throws Exception {
    String[] securities = {"RYA ID Equity", "OCN US Equity"};
    String[] fields = {"CRNCY_ADJ_MKT_CAP", "CUR_MKT_CAP"};
    String[] override_fields = {"EQY_FUND_CRNCY"};
    String[] overrides = {"JPY"};

    DataResult result = conn.blp(securities, fields, override_fields, overrides);
    String[][] data = result.getData();

    System.out.println(data[0][0]);
    System.out.println(data[0][1]);
    System.out.println(data[1][0]);
    System.out.println(data[1][1]);
  }

  public void testValidRequestWithInvalidOverrides() throws Exception {
    String[] securities = {"RYA ID Equity", "OCN US Equity"};
    String[] fields = {"NAME", "BID", "LOW_DT_52WEEK"};
    String[] override_fields = {"PRICING SOURCE"};
    String[] overrides = {"CG"};

    try {
      conn.blp(securities, fields, override_fields, overrides);
      fail("Should have raised an error");
    } catch (WrapperException e) {
      System.out.println(e.getMessage());
      boolean b = Pattern.matches("^response error: Invalid override field: PRICING SOURCE.*$", e.getMessage());
      assertTrue("unexpected message", b);
    }
  }

  public void testPassingOptions() throws Exception {
    String[] securities = {"AMZN US Equity"};
    String[] fields = {"PX_LAST"};
    String[] override_fields = new String[0];
    String[] overrides = new String[0];
    String[] option_names = {"returnFormattedValue"};
    String[] option_values = {"true"};

    DataResult result = conn.blp(securities, fields, override_fields, overrides);
    assertEquals("FLOAT64", result.getDataTypes()[0]);

    result = conn.blp(securities, fields, override_fields, overrides, option_names, option_values);
    assertEquals("STRING", result.getDataTypes()[0]);
  }

  public void testHugeRequest() throws Exception {
    String[] securities = 
    {"ABBY ID Equity"   , "AERL ID Equity"   , "AEX ID Equity"    ,
      "AGI ID Equity"    , "ALBK ID Equity"   , "BCP ID Equity"    ,
      "BKIR ID Equity"   , "BLK ID Equity"    , "CDG ID Equity"    ,
      "CPL ID Equity"    , "CRH ID Equity"    , "DCC ID Equity"    ,
      "DCP ID Equity"    , "DGO ID Equity"    , "DLE ID Equity"    ,
      "ELN ID Equity"    , "FBD ID Equity"    , "FDP ID Equity"    ,
      "FFY ID Equity"    , "GCC ID Equity"    , "GLB ID Equity"    ,
      "GN5 ID Equity"    , "GNC ID Equity"    , "ICON ID Equity"   ,
      "IFP ID Equity"    , "INM ID Equity"    , "IPM ID Equity"    ,
      "IR5A ID Equity"   , "KDR ID Equity"    , "KMR ID Equity"    ,
      "KSP ID Equity"    , "KYG ID Equity"    , "MCI ID Equity"    ,
      "MERR ID Equity"   , "NORK ID Equity"   , "OGB ID Equity"    ,
      "OGN ID Equity"    , "ORM ID Equity"    , "OVG ID Equity"    ,
      "PACC ID Equity"   , "PCI ID Equity"    , "PRP ID Equity"    ,
      "PTR ID Equity"    , "PWL ID Equity"    , "REO ID Equity"    ,
      "RYA ID Equity"    , "RYX ID Equity"    , "SKG ID Equity"    ,
      "SSV ID Equity"    , "TOT ID Equity"    , "TVCH ID Equity"   ,
      "UDG ID Equity"    , "UTV ID Equity"    , "WSPR ID Equity"   ,
      "YZA ID Equity"    , "ZMNO ID Equity"   , "AAB DC Equity"    ,
      "AARHUS DC Equity" , "AFFI DC Equity"   , "ALKB DC Equity"   ,
      "ALMB DC Equity"   , "ALMBFB DC Equity" , "ALMBPB DC Equity" ,
      "AMAG DC Equity"   , "AMB DC Equity"    , "AMBUB DC Equity"  ,
      "AOJP DC Equity"   , "ASGDEV DC Equity" , "ATLA DC Equity"   ,
      "AURIB DC Equity"  , "BAVA DC Equity"   , "BERL3B DC Equity" ,
      "BIFB DC Equity"   , "BIOPOR DC Equity" , "BLVIS DC Equity"  ,
      "BO DC Equity"     , "BOCONB DC Equity" , "BORDB DC Equity"  ,
      "CAPI DC Equity"   , "CARLA DC Equity"  , "CARLB DC Equity"  ,
      "CBRAIN DC Equity" , "CHEMM DC Equity"  , "CIMBER DC Equity" ,
      "COLOB DC Equity"  , "COLUM DC Equity"  , "COM DC Equity"    ,
      "DANIO DC Equity"  , "DANSKE DC Equity" , "DANTB DC Equity"  ,
      "DANTH DC Equity"  , "DANTR DC Equity"  , "DCO DC Equity"    ,
      "DEH DC Equity"    , "DELTAQ DC Equity" , "DFDS DC Equity"   ,
      "DIBA DC Equity"   , "DJUR DC Equity"   , "DKTI DC Equity"   ,
      "DLHB DC Equity"   , "DNORD DC Equity"  , "DSV DC Equity"    ,
      "EAC DC Equity"    , "EGEB DC Equity"   , "EI DC Equity"     ,
      "EIK DC Equity"    , "EITZEN DC Equity" , "ELITEB DC Equity" ,
      "ERRI DC Equity"   , "EXPB DC Equity"   , "EXQ DC Equity"    ,
      "FEI DC Equity"    , "FEII DC Equity"   , "FFARMS DC Equity" ,
      "FLS DC Equity"    , "FLUGB DC Equity"  , "FOAIR DC Equity"  ,
      "FOBANK DC Equity" , "FPEPI DC Equity"  , "FPLIM DC Equity"  ,
      "FPMER DC Equity"  , "FPOPT DC Equity"  , "FPPAR DC Equity"  ,
      "FPPEN DC Equity"  , "FPSAFE DC Equity" , "GABR DC Equity"   ,
      "GEN DC Equity"    , "GES DC Equity"    , "GJ DC Equity"     ,
      "GN DC Equity"     , "GR4SEC DC Equity" , "GRIFIVB DC Equity",
      "GRLA DC Equity"   , "GW DC Equity"     , "GYLDA DC Equity"  ,
      "GYLDB DC Equity"  , "HARBB DC Equity"  , "HART DC Equity"   ,
      "HH DC Equity"     , "HOEJA DC Equity"  , "HOEJB DC Equity"  ,
      "HOLD DC Equity"   , "HVETBO DC Equity" , "HVID DC Equity"   ,
      "IC DC Equity"     , "IGHS2B DC Equity" , "IMAILB DC Equity" ,
      "ISPB DC Equity"   , "JDAN DC Equity"   , "JMI DC Equity"    ,
      "JYSK DC Equity"   , "KAP DC Equity"    , "KBHL DC Equity"   ,
      "KLEEB DC Equity"  , "KLIMA DC Equity"  , "KRE DC Equity"    ,
      "LASP DC Equity"   , "LASTB DC Equity"  , "LCP DC Equity"    ,
      "LLA DC Equity"    , "LLB DC Equity"    , "LOLB DC Equity"   ,
      "LUN DC Equity"    , "LUXORB DC Equity" , "MACO DC Equity"   ,
      "MAERSKA DC Equity", "MAERSKB DC Equity", "MAX DC Equity"    ,
      "MIGAB DC Equity"  , "MNBA DC Equity"   , "MOLS DC Equity"   ,
      "MORS DC Equity"   , "MTB DC Equity"    , "NDA DC Equity"    ,
      "NETOP DC Equity"  , "NEUR DC Equity"   , "NKT DC Equity"    ,
      "NORDIC DC Equity" , "NORDJB DC Equity" , "NOVOB DC Equity"  ,
      "NRDC DC Equity"   , "NRDF DC Equity"   , "NRSU DC Equity"   ,
      "NTRB DC Equity"   , "NUNA DC Equity"   , "NZYMB DC Equity"  ,
      "OAHB DC Equity"   , "OJBA DC Equity"   , "OLI DC Equity"    ,
      "OSSR DC Equity"   , "PAALB DC Equity"  , "PARKEN DC Equity" ,
      "PRIMOF DC Equity" , "RBLNB DC Equity"  , "RBREW DC Equity"  ,
      "RELLA DC Equity"  , "RIASB DC Equity"  , "RILBA DC Equity"  ,
      "ROCKA DC Equity"  , "ROCKB DC Equity"  , "ROV DC Equity"    ,
      "RTX DC Equity"    , "SALB DC Equity"   , "SANIB DC Equity"  ,
      "SAS DC Equity"    , "SAT DC Equity"    , "SBS DC Equity"    ,
      "SCD DC Equity"    , "SCFT DC Equity"   , "SCHAUP DC Equity" ,
      "SCHO DC Equity"   , "SIFB DC Equity"   , "SIM DC Equity"    ,
      "SJGR DC Equity"   , "SKAKOI DC Equity" , "SKJE DC Equity"   ,
      "SKLS DC Equity"   , "SOEN DC Equity"   , "SOLARB DC Equity" ,
      "SPALOL DC Equity" , "SPB DC Equity"    , "SPEAS DC Equity"  ,
      "SPFA DC Equity"   , "SPG DC Equity"    , "SPHIM DC Equity"  ,
      "SPNCA DC Equity"  , "SPNCB DC Equity"  , "SPNFI DC Equity"  ,
      "SPNO DC Equity"   , "SVEND DC Equity"  , "SYDB DC Equity"   ,
      "TDC DC Equity"    , "THRAN DC Equity"  , "TIV DC Equity"    ,
      "TKDV DC Equity"   , "TNDR DC Equity"   , "TOP DC Equity"    ,
      "TOPO DC Equity"   , "TORM DC Equity"   , "TOTA DC Equity"   ,
      "TOWER DC Equity"  , "TPSL DC Equity"   , "TRIFOR DC Equity" ,
      "TRYG DC Equity"   , "UIE DC Equity"    , "UPAL DC Equity"   ,
      "UPB DC Equity"    , "VEFY DC Equity"   , "VIBHK DC Equity"  ,
      "VIINT DC Equity"  , "VIND DC Equity"   , "VIPRO DC Equity"  ,
      "VJBA DC Equity"   , "VORD DC Equity"   , "VWS DC Equity"    ,
      "WALLS DC Equity"  , "WDH DC Equity"    , "A3TV SM Equity"   ,
      "ABE SM Equity"    , "ABG SM Equity"    , "ACS SM Equity"    ,
      "ACX SM Equity"    , "ADZ SM Equity"    , "AFR SM Equity"    ,
      "ALB SM Equity"    , "ALM SM Equity"    , "AMP SM Equity"    ,
      "ANA SM Equity"    , "AVZ SM Equity"    , "AZK SM Equity"    ,
      "BBVA SM Equity"   , "BDL SM Equity"    , "BIO SM Equity"    ,
      "BKT SM Equity"    , "BMA SM Equity"    , "BME SM Equity"    ,
      "BTO SM Equity"    , "BVA SM Equity"    , "CAF SM Equity"    ,
      "CAM SM Equity"    , "CBAV SM Equity"   , "CDR SM Equity"    ,
      "CEP SM Equity"    , "CFG SM Equity"    , "CIE SM Equity"    };

    String[] fields = {"NAME", "COUNTRY", "INDUSTRY_SECTOR", "PX_LAST", "EXCH_CODE", "ID_ISIN", "CRNCY_ADJ_MKT_CAP", "CHG_PCT_YTD", "DVD_PAYOUT_RATIO", "TOT_ANALYST_REC", "ALTMAN_Z_SCORE", "BEST_EEPS_NXT_YR", "BEST_EEPS_CUR_YR", "SALES_GROWTH", "BEST_EST_PE_NXT_YR", "RETURN_ON_CAP", "WACC_TOTAL_CAPITAL", "TOT_BUY_REC", "LT_DEBT_TO_COM_EQY", "RETURN_COM_EQY"};

//    DataResult result = conn.blp(securities, fields);
  }
}
