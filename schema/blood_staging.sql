DROP TABLE IF EXISTS ct_biochemistry;

CREATE TABLE ct_biochemistry (
-- Comments: 
-- CREATE ANY INDEXES ...
--

  Table_ID integer(20) not null primary key,
  HospNo char(24) NOT NULL CONSTRAINT ct_biochemistry_hospno_id REFERENCES dbo_Root(HospitalNumber),
  ResDate timestamp,
  ResTime timestamp,
  ResName char(100),
  ResValue char(150)
);

DROP TABLE IF EXISTS ct_bloodbank;

CREATE TABLE ct_bloodbank (
-- Comments: 
-- MDB Tools - A library for reading MS Access database files
-- Copyright (C) 2000-2004 Brian Bruns
-- Files in libmdb are licensed under LGPL and the utilities under
-- the GPL, see COPYING.LIB and COPYING files respectively.
-- Check out http://mdbtools.sourceforge.net
--

  Table_ID integer(20) not null primary key,
  HospNo char(24) NOT NULL CONSTRAINT ct_bloodbank_hospno_id REFERENCES dbo_Root(HospitalNumber),
  ResDate timestamp,
  ResTime timestamp,
  ResName char(100),
  ResValue char(150)
);

DROP TABLE IF EXISTS ct_haematology;

CREATE TABLE ct_haematology (
-- Comments: 
-- CREATE ANY INDEXES ...
--

  Table_ID integer(20) not null primary key,
  HospNo char(24) NOT NULL CONSTRAINT ct_haematology_hospno_id REFERENCES dbo_Root(HospitalNumber),
  ResDate timestamp,
  ResTime timestamp,
  ResName char(100),
  ResValue char(150)
);

DROP TABLE IF EXISTS ct_othertests;

CREATE TABLE ct_othertests (
-- Comments: 
-- CREATE ANY INDEXES ...
--

  Table_ID integer(20) not null primary key,
  HospNo char(24) NOT NULL CONSTRAINT ct_othertests_hospno_id REFERENCES dbo_Root(HospitalNumber),
  ResDate timestamp,
  ResTime timestamp,
  ResName char(100),
  ResValue char(150)
);

DROP TABLE IF EXISTS ct_virology;

CREATE TABLE ct_virology (
-- Comments: 
-- CREATE ANY INDEXES ...
--

  Table_ID integer(20) not null primary key,
  HospNo char(24) NOT NULL CONSTRAINT ct_virology_hospno_id REFERENCES dbo_Root(HospitalNumber),
  ResDate timestamp,
  ResTime timestamp,
  ResName char(100),
  ResValue char(150)
);

DROP TABLE IF EXISTS dbo_Biochemistry;

CREATE TABLE dbo_Biochemistry (
-- Comments: 
-- CREATE ANY INDEXES ...
--

  BiochemistryID integer(20) not null primary key,
  HospitalNumber char(24) NOT NULL CONSTRAINT dbo_biochemistry_hospno_id REFERENCES dbo_Root(HospitalNumber),
  Specimen char(60),
  ResultDate timestamp,
  '24hrUrineCalcium' char(150),
  '24hrUrineCreatinine' char(150),
  '24hrUrineDopamine' char(150),
  '24hrUrinePhosphate' char(150),
  '24hrUrinePotassium' char(150),
  '24hrUrineSodium' char(150),
  '24hrUrineProtein' char(150),
  '24hrUrineVolume' char(150),
  ACR char(150),
  ACTH char(150),
  Albumin char(150),
  Aldosterone char(150),
  ALP char(150),
  ALT char(150),
  Amylase char(150),
  Bicarb char(150),
  Bilirubin char(150),
  Calcium char(150),
  Cholesterol char(150),
  Chol_HDL_ratio char(150),
  Ciclosporin char(150),
  Corrected_Calcium char(150),
  Cortisol char(150),
  Creatinine char(150),
  CreatinineClearance char(150),
  CRP char(150),
  DHEAsulphate char(150),
  Ferritin char(150),
  FSH char(150),
  GFR char(6),
  Glucose char(150),
  GrowthHormone char(150),
  GST char(150),
  HbA1c char(150),
  HDL_cholesterol char(150),
  IgF char(150),
  Lactate char(150),
  LDL_cholesterol char(150),
  LH char(150),
  Lipase char(150),
  Magnesium char(150),
  Oestradiol char(150),
  Osmolality char(150),
  Phosphate char(150),
  Potassium char(150),
  Prolactin char(150),
  PTH char(150),
  PTHpmol char(150),
  Red_Cell_Folate char(150),
  Renin char(150),
  Saturation char(150),
  Serum_Iron char(150),
  SexHormoneBindingGlobulin char(150),
  Sirolimus char(150),
  Sodium char(150),
  T3 char(150),
  T4 char(150),
  Tacrolimus char(150),
  Testosterone char(150),
  Total_CK char(150),
  Triglyceride char(150),
  Transferrin char(150),
  TSH char(150),
  Urea char(150),
  Uric_Acid char(150),
  UrineFreeCortisol char(150),
  UrineOsmolality char(150),
  UrinePotassium char(150),
  UrineSodium char(150),
  Urine5HIAA char(150),
  UrineUFCAT char(150),
  UrineVMA char(150),
  VitaminB12 char(150),
  UpdateDateTime timestamp
);

DROP TABLE IF EXISTS dbo_BloodBank;

CREATE TABLE dbo_BloodBank (
-- Comments: 
-- CREATE ANY INDEXES ...
--

  BloodBankID integer(20) not null primary key,
  HospitalNumber char(24) NOT NULL CONSTRAINT dbo_bloodbank_hospno_id REFERENCES dbo_Root(HospitalNumber),
  Specimen char(60),
  ResultDate timestamp,
  BloodGroup char(150),
  HLAA1 char(150),
  HLAA2 char(150),
  HLAB1 char(150),
  HLAB2 char(150),
  HLABw char(150),
  HLAC1 char(150),
  HLAC2 char(150),
  HLADQ1 char(150),
  HLADQ2 char(150),
  HLADR1 char(150),
  HLADR2 char(150),
  PercentPBL char(150),
  PercentPBLstrong char(150),
  PercentPBLIgG char(150),
  PercentPBLIgGstrong char(150),
  PercentCLL char(150),
  PercentCLLstrong char(150),
  PercentCLLIgG char(150),
  PercentCLLIgGstrong char(150),
  ElisaI char(150),
  ElisaII char(150),
  LuminexI char(150),
  LuminexII char(150),
  ListDate char(150),
  BloodTransfusions char(150),
  DiseaseCodes char(150),
  EthnicOrigin char(150),
  Events char(150),
  Pregnancies char(150),
  UKTnumber char(150),
  AntibodySpecificities1 char(150),
  AntibodySpecificities2 char(150),
  RowUpdateDateTime timestamp
);

DROP TABLE IF EXISTS dbo_Haematology;

CREATE TABLE dbo_Haematology (
-- Comments: 
-- CREATE ANY INDEXES ...
--

  HaematologyID integer(20) not null primary key,
  HospitalNumber char(24) NOT NULL CONSTRAINT dbo_haematology_hospno_id REFERENCES dbo_Root(HospitalNumber),
  Specimen char(60),
  ResultDate timestamp,
  APTT char(150),
  Eosinophils char(150),
  Haemoglobin char(150),
  INR char(150),
  Neutrophils char(150),
  Plts char(150),
  PT char(150),
  WBC char(150),
  Lymphocytes char(150),
  ESR char(150),
  MCV char(150),
  Haematocrit char(150),
  UpdateDateTime timestamp
);

DROP TABLE IF EXISTS dbo_LatestResults;

CREATE TABLE dbo_LatestResults (
-- Comments: 
-- CREATE ANY INDEXES ...
--

  HospitalNumber char(24) NOT NULL CONSTRAINT dbo_latest_results_hospno_id REFERENCES dbo_Root(HospitalNumber),
  ACRDate timestamp,
  ACR Numeric(9),
  BloodGroupDate timestamp,
  BloodGroup char(20),
  CreatinineDate timestamp,
  Creatinine Numeric(9),
  CreatinineClearanceDate timestamp,
  CreatinineClearance Numeric(9),
  UreaDate timestamp,
  Urea Numeric(9),
  SodiumDate timestamp,
  Sodium Numeric(9),
  PotassiumDate timestamp,
  Potassium Numeric(9),
  BicarbDate timestamp,
  Bicarb Numeric(9),
  GlucoseDate timestamp,
  Glucose Numeric(9),
  CalciumDate timestamp,
  Calcium Numeric(9),
  CorrectedCalciumDate timestamp,
  CorrectedCalcium Numeric(9),
  PhosphateDate timestamp,
  Phosphate Numeric(9),
  CholesterolDate timestamp,
  Cholesterol Numeric(9),
  HDLDate timestamp,
  HDL Numeric(9),
  AlbuminDate timestamp,
  Albumin Numeric(9),
  AlkPhosDate timestamp,
  AlkPhos Numeric(9),
  BilirubinDate timestamp,
  Bilirubin Numeric(9),
  ALTDate timestamp,
  ALT Numeric(9),
  CRPDate timestamp,
  CRP Numeric(9),
  CiclosporinDate timestamp,
  Ciclosporin Numeric(9),
  TacrolimusDate timestamp,
  Tacrolimus Numeric(9),
  SirolimusDate timestamp,
  Sirolimus Numeric(9),
  AmylaseDate timestamp,
  Amylase Numeric(9),
  LipaseDate timestamp,
  Lipase Numeric(9),
  UricAcidDate timestamp,
  UricAcid Numeric(9),
  FerritinDate timestamp,
  Ferritin Numeric(9),
  RedCellFolateDate timestamp,
  RedCellFolate Numeric(9),
  VitaminB12Date timestamp,
  VitaminB12 Numeric(9),
  HbA1cDate timestamp,
  HbA1c Numeric(9),
  PTHDate timestamp,
  PTH Numeric(9),
  HaemoglobinDate timestamp,
  Haemoglobin Numeric(9),
  LymphocytesDate timestamp,
  Lymphocytes Numeric(9),
  WBCDate timestamp,
  WBC Numeric(9),
  PltsDate timestamp,
  Plts Numeric(9),
  PTDate timestamp,
  PT Numeric(9),
  APTTDate timestamp,
  APTT Numeric(9),
  INRDate timestamp,
  INR Numeric(9),
  EosinophilsDate timestamp,
  Eosinophils Numeric(9),
  NeutrophilsDate timestamp,
  Neutrophils Numeric(9),
  CMVLatexDate timestamp,
  CMVLatex char(150),
  CMVIgGDate timestamp,
  CMVIgG char(150),
  HepBsAgDate timestamp,
  HepBsAg char(150),
  HepCDate timestamp,
  HepC char(150),
  ToxoDate timestamp,
  Toxo char(150),
  HSVDate timestamp,
  HSV char(150),
  VZVDate timestamp,
  VZV char(150),
  HIVDate timestamp,
  HIV char(150),
  AntiHepBsAgAbDate timestamp,
  AntiHepBsAgAb Numeric(9),
  EBV_VCA_IgGDate timestamp,
  EBV_VCA_IgG char(150),
  TotalCKDate timestamp,
  TotalCK Numeric(9),
  GFRdate timestamp,
  GFR char(6),
  MELDdate timestamp,
  MELD integer(20),
  UKELDdate timestamp,
  UKELD integer(20)
);

DROP TABLE IF EXISTS dbo_OtherTests;

CREATE TABLE dbo_OtherTests (
-- Comments: 
-- CREATE ANY INDEXES ...
--

  OtherTestsID integer(20) not null primary key,
  HospitalNumber char(24) NOT NULL CONSTRAINT dbo_othertests_hospno_id REFERENCES dbo_Root(HospitalNumber),
  Specimen char(60),
  ResultDate timestamp,
  Caeruloplasmin char(150),
  AFP char(150),
  CA19point9 char(150),
  Alpha1AntiTrypsinGenotype char(150),
  ANA_elisa_ENA_DNA_Centromere char(150),
  AntiMitochondrial char(150),
  AntiSmoothMuscle char(150),
  AntiLKM char(150),
  ANCA_IF char(150),
  ANCA_MP0 char(150),
  ANCA_PR3 char(150),
  RheumatoidFactor char(150),
  IgA char(150),
  IgG char(150),
  IgM char(150),
  Cryoglobulin char(150),
  ComplementC3 char(150),
  ComplementC4 char(150),
  AntiDNA char(150),
  CD3percent char(150),
  CD3total char(150),
  CD4percent char(150),
  CD4total char(150),
  CD8percent char(150),
  CD8total char(150),
  CD19percent char(150),
  CD19total char(150),
  CD56percent char(150),
  CD56total char(150),
  WhiteBloodCellCount char(150),
  LymphocyteCount char(150),
  UpdateDateTime timestamp
);

DROP TABLE IF EXISTS dbo_Report;

CREATE TABLE dbo_Report (
-- Comments: 
-- CREATE ANY INDEXES ...
--

  ReportID integer(20) not null primary key,
  TextID integer(20),
  ReportText char(180),
  HospitalNumber char(24) NOT NULL CONSTRAINT dbo_report_hospno_id REFERENCES dbo_Root(HospitalNumber),
  SpecimenID char(60),
  ReceivedDateTime timestamp,
  RowUpdateDateTime timestamp
);

DROP TABLE IF EXISTS dbo_Root;

CREATE TABLE dbo_Root (
-- Comments: 
-- CREATE ANY INDEXES ...
--

  HospitalNumber char(24) not null primary key,
  MergedToRecord char(24),
  NHSNumber char(24),
  UKTNumber integer(20),
  RenalRegistryNumber char(40),
  Title char(100),
  Forename char(200),
  Surname char(100),
  Gender char(2),
  DoBEventId integer(20),
  DateOfBirth timestamp,
  DoDEventId integer(20),
  DateOfDeath timestamp,
  CauseOfDeathCodeId integer(20),
  CauseOfDeathComment char(400),
  ReferringHospitalNumber char(100),
  ReferringPhysicianCodeId integer(20),
  ReferringCentreCodeID integer(20),
  Occupation char(100),
  ResidentialAddress1 char(100),
  ResidentialAddress2 char(100),
  ResidentialAddress3 char(100),
  ResidentialAddress4 char(100),
  ResidentialPostCode char(100),
  HISSPhone1 char(100),
  HISSPhone2 char(100),
  HealthAuthority char(100),
  GPTitle char(100),
  GPName char(100),
  GPAddressName char(100),
  GPAddress1 char(100),
  GPAddress2 char(100),
  GPAddress3 char(100),
  GPAddress4 char(100),
  GPPostCode char(100),
  GPTelephone char(50),
  GPFax char(100),
  ESRFEventId integer(20),
  ESRFDate timestamp,
  EthnicOriginCodeID integer(20),
  LiveDonorYN boolean,
  LiverPatientYN boolean,
  PancreasPatientYN boolean,
  RenalPatientYN boolean,
  VasculitisPatientYN boolean,
  DeletedYn boolean,
  Nee char(100),
  NeeComment char(100),
  SeeKB char(100),
  EthnicOrigin char(20),
  MenuTypeCodeId integer(20),
  FollowUpCentreCodeID integer(20),
  PatientName char(304),
  RegisteredOnHISS boolean,
  ProtonHospitalNumber char(24),
  PCG char(20),
  Nat_Insurance_Number char(40),
  Marital_Status char(40),
  Nationality char(40),
  Religion char(40),
  Chronic_Sick_Disabled char(2),
  NOK_Name char(100),
  NOK_Addr_1 char(200),
  NOK_Addr_2 char(200),
  NOK_Addr_3 char(200),
  NOK_Addr_4 char(200),
  NOK_Post_Code char(60),
  NOK_Home_Phone_Number char(100),
  NOK_Work_Phone_Number char(100),
  NOK_Relation char(40),
  OLTNumber integer(20),
  BloodGroup char(24),
  ALTALabel boolean,
  Alert char(400),
  FollowUpCentre char(100),
  MobileTelephone char(100),
  OtherTelephone1 char(100),
  OtherTelephone1Description char(100),
  OtherTelephone2 char(100),
  OtherTelephone2Description char(100),
  OtherTelephone3 char(30),
  OtherTelephone3Description char(100),
  OtherTelephone4 char(30),
  OtherTelephone4Description char(100),
  PagerNumber char(30),
  ReferringConsultantCodeId integer(20),
  LastUpdatedFromHISS timestamp
);

DROP TABLE IF EXISTS dbo_TestCode;

CREATE TABLE dbo_TestCode (
-- Comments: 
-- CREATE ANY INDEXES ...
--

  TestCodeID integer(20) not null primary key,
  TestID char(18),
  TestName char(60),
  Lab char(2),
  TableName char(100),
  FieldName char(200)
);

DROP TABLE IF EXISTS dbo_Virology;

CREATE TABLE dbo_Virology (
-- Comments: 
-- CREATE ANY INDEXES ...
--

  VirologyID integer(20) not null primary key,
  HospitalNumber char(24) NOT NULL CONSTRAINT dbo_virology_hospno_id REFERENCES dbo_Root(HospitalNumber),
  Specimen char(60),
  ResultDate timestamp,
  CMV_IgG char(150),
  CMV_Latex char(150),
  HepBsAg char(150),
  HepC char(150),
  HIV char(150),
  HSV char(150),
  Toxo char(150),
  VZV char(150),
  Anti_HBs_post_vaccination char(150),
  EBV_VCA_IgG char(150),
  UpdateDateTime timestamp
);

DROP TABLE IF EXISTS exp_ct_biochem_concat;

CREATE TABLE exp_ct_biochem_concat (
-- Comments: 
-- CREATE ANY INDEXES ...
--

  HospNo char(24) NOT NULL CONSTRAINT exp_ct_biochem_concat_hospno_id REFERENCES dbo_Root(HospitalNumber),
  ResDate timestamp,
  ResTime timestamp,
  '24hrUrineCalcium' char(510),
  '24hrUrineCreatinine' char(510),
  '24hrUrineDopamine' char(510),
  '24hrUrinePhosphate' char(510),
  '24hrUrinePotassium' char(510),
  '24hrUrineProtein' char(510),
  '24hrUrineSodium' char(510),
  '24hrUrineVolume' char(510),
  ACR char(510),
  ACTH char(510),
  Albumin char(510),
  Aldosterone char(510),
  ALP char(510),
  ALT char(510),
  Amylase char(510),
  Bicarb char(510),
  Bilirubin char(510),
  Calcium char(510),
  Chol_HDL_ratio char(510),
  Cholesterol char(510),
  Ciclosporin char(510),
  Corrected_Calcium char(510),
  Cortisol char(510),
  Creatinine char(510),
  CreatinineClearance char(510),
  CRP char(510),
  DHEAsulphate char(510),
  Ferritin char(510),
  FSH char(510),
  Glucose char(510),
  GrowthHormone char(510),
  HbA1c char(510),
  HDL_cholesterol char(510),
  IgF char(510),
  LDL_cholesterol char(510),
  LH char(510),
  Magnesium char(510),
  Oestradiol char(510),
  Osmolality char(510),
  Phosphate char(510),
  Potassium char(510),
  Prolactin char(510),
  PTH char(510),
  PTHpmol char(510),
  Red_Cell_Folate char(510),
  Renin char(510),
  Serum_Iron char(510),
  Sodium char(510),
  T3 char(510),
  Tacrolimus char(510),
  Testosterone char(510),
  Transferrin char(510),
  Triglyceride char(510),
  TSH char(510),
  Urea char(510),
  Uric_Acid char(510),
  Urine5HIAA char(510),
  UrineFreeCortisol char(510),
  UrineOsmolality char(510),
  UrinePotassium char(510),
  UrineSodium char(510),
  UrineVMA char(510),
  VitaminB12 char(510),
  Table_ID integer(20) not null primary key
);

DROP TABLE IF EXISTS exp_ct_bloodbank_concat;

CREATE TABLE exp_ct_bloodbank_concat (
-- Comments: 
-- CREATE ANY INDEXES ...
--

  HospNo char(24) NOT NULL CONSTRAINT exp_ct_bloodbank_concat_hospno_id REFERENCES dbo_Root(HospitalNumber),
  ResDate timestamp,
  ResTime timestamp,
  AntibodySpecificities1 char(510),
  AntibodySpecificities2 char(510),
  BloodGroup char(510),
  BloodTransfusions char(510),
  DiseaseCodes char(510),
  ElisaI char(510),
  ElisaII char(510),
  EthnicOrigin char(510),
  Events char(510),
  HLAA1 char(510),
  HLAA2 char(510),
  HLAB1 char(510),
  HLAB2 char(510),
  HLABw char(510),
  HLAC1 char(510),
  HLAC2 char(510),
  HLADQ1 char(510),
  HLADQ2 char(510),
  HLADR1 char(510),
  HLADR2 char(510),
  ListDate char(510),
  LuminexI char(510),
  LuminexII char(510),
  PercentCLL char(510),
  PercentCLLIgG char(510),
  PercentCLLIgGstrong char(510),
  PercentCLLstrong char(510),
  PercentPBL char(510),
  PercentPBLIgG char(510),
  PercentPBLIgGstrong char(510),
  PercentPBLstrong char(510),
  Pregnancies char(510),
  UKTnumber char(510),
  Table_ID integer(20) not null primary key
);

DROP TABLE IF EXISTS exp_ct_haematol_concat;

CREATE TABLE exp_ct_haematol_concat (
-- Comments: 
-- CREATE ANY INDEXES ...
--

  HospNo char(24) NOT NULL CONSTRAINT exp_ct_haematol_concat_hospno_id REFERENCES dbo_Root(HospitalNumber),
  ResDate timestamp,
  ResTime timestamp,
  APTT char(510),
  Eosinophils char(510),
  ESR char(510),
  Haematocrit char(510),
  Haemoglobin char(510),
  INR char(510),
  Lymphocytes char(510),
  MCV char(510),
  Neutrophils char(510),
  Plts char(510),
  PT char(510),
  WBC char(510),
  Table_ID integer(20) not null primary key
);

DROP TABLE IF EXISTS exp_ct_other_concat;

CREATE TABLE exp_ct_other_concat (
-- Comments: 
-- CREATE ANY INDEXES ...
--

  HospNo char(24) NOT NULL CONSTRAINT exp_ct_other_concat_hospno_id REFERENCES dbo_Root(HospitalNumber),
  ResDate timestamp,
  ResTime timestamp,
  AFP char(510),
  ANA_elisa_ENA_DNA_Centromere char(510),
  ANCA_IF char(510),
  ANCA_MP0 char(510),
  ANCA_PR3 char(510),
  AntiDNA char(510),
  AntiLKM char(510),
  AntiMitochondrial char(510),
  AntiSmoothMuscle char(510),
  CA19point9 char(510),
  Caeruloplasmin char(510),
  CD19percent char(510),
  CD19total char(510),
  CD3percent char(510),
  CD3total char(510),
  CD4percent char(510),
  CD4total char(510),
  CD56total char(510),
  CD8percent char(510),
  CD8total char(510),
  ComplementC3 char(510),
  ComplementC4 char(510),
  Cryoglobulin char(510),
  IgA char(510),
  IgG char(510),
  IgM char(510),
  LymphocyteCount char(510),
  RheumatoidFactor char(510),
  WhiteBloodCellCount char(510),
  Table_ID integer(20) not null primary key
);

DROP TABLE IF EXISTS exp_ct_virology_concat;

CREATE TABLE exp_ct_virology_concat (
-- Comments: 
-- CREATE ANY INDEXES ...
--

  HospNo char(24) NOT NULL CONSTRAINT exp_ct_virology_concat_hospno_id REFERENCES dbo_Root(HospitalNumber),
  ResDate timestamp,
  ResTime timestamp,
  Anti_HBs_post_vaccination char(510),
  CMV_IgG char(510),
  EBV_VCA_IgG char(510),
  HepBsAg char(510),
  HepC char(510),
  HIV char(510),
  HSV char(510),
  Toxo char(510),
  VZV char(510),
  Table_ID integer(20) not null primary key
);

--
-- Autogenerated triggers to maintain integrity
--
-- Drop Trigger
DROP TRIGGER IF EXISTS fki_ct_biochemistry_HospNo_dbo_Root_HospitalNumber;

-- Foreign Key Preventing insert
CREATE TRIGGER fki_ct_biochemistry_HospNo_dbo_Root_HospitalNumber
BEFORE INSERT ON [ct_biochemistry]
FOR EACH ROW BEGIN
  SELECT RAISE(ROLLBACK, 'insert on table "ct_biochemistry" violates foreign key constraint "fki_ct_biochemistry_HospNo_dbo_Root_HospitalNumber"')
  WHERE (SELECT HospitalNumber FROM dbo_Root WHERE HospitalNumber = NEW.HospNo) IS NULL;
END;

-- Drop Trigger
DROP TRIGGER IF EXISTS fku_ct_biochemistry_HospNo_dbo_Root_HospitalNumber;

-- Foreign key preventing update
CREATE TRIGGER fku_ct_biochemistry_HospNo_dbo_Root_HospitalNumber
BEFORE UPDATE ON [ct_biochemistry]
FOR EACH ROW BEGIN
    SELECT RAISE(ROLLBACK, 'update on table "ct_biochemistry" violates foreign key constraint "fku_ct_biochemistry_HospNo_dbo_Root_HospitalNumber"')
      WHERE (SELECT HospitalNumber FROM dbo_Root WHERE HospitalNumber = NEW.HospNo) IS NULL;
END;

-- Drop Trigger
DROP TRIGGER IF EXISTS fkd_ct_biochemistry_HospNo_dbo_Root_HospitalNumber;

-- Foreign key preventing delete
CREATE TRIGGER fkd_ct_biochemistry_HospNo_dbo_Root_HospitalNumber
BEFORE DELETE ON dbo_Root
FOR EACH ROW BEGIN
  SELECT RAISE(ROLLBACK, 'delete on table "dbo_Root" violates foreign key constraint "fkd_ct_biochemistry_HospNo_dbo_Root_HospitalNumber"')
  WHERE (SELECT HospNo FROM ct_biochemistry WHERE HospNo = OLD.HospitalNumber) IS NOT NULL;
END;

-- Drop Trigger
DROP TRIGGER IF EXISTS fki_ct_bloodbank_HospNo_dbo_Root_HospitalNumber;

-- Foreign Key Preventing insert
CREATE TRIGGER fki_ct_bloodbank_HospNo_dbo_Root_HospitalNumber
BEFORE INSERT ON [ct_bloodbank]
FOR EACH ROW BEGIN
  SELECT RAISE(ROLLBACK, 'insert on table "ct_bloodbank" violates foreign key constraint "fki_ct_bloodbank_HospNo_dbo_Root_HospitalNumber"')
  WHERE (SELECT HospitalNumber FROM dbo_Root WHERE HospitalNumber = NEW.HospNo) IS NULL;
END;

-- Drop Trigger
DROP TRIGGER IF EXISTS fku_ct_bloodbank_HospNo_dbo_Root_HospitalNumber;

-- Foreign key preventing update
CREATE TRIGGER fku_ct_bloodbank_HospNo_dbo_Root_HospitalNumber
BEFORE UPDATE ON [ct_bloodbank]
FOR EACH ROW BEGIN
    SELECT RAISE(ROLLBACK, 'update on table "ct_bloodbank" violates foreign key constraint "fku_ct_bloodbank_HospNo_dbo_Root_HospitalNumber"')
      WHERE (SELECT HospitalNumber FROM dbo_Root WHERE HospitalNumber = NEW.HospNo) IS NULL;
END;

-- Drop Trigger
DROP TRIGGER IF EXISTS fkd_ct_bloodbank_HospNo_dbo_Root_HospitalNumber;

-- Foreign key preventing delete
CREATE TRIGGER fkd_ct_bloodbank_HospNo_dbo_Root_HospitalNumber
BEFORE DELETE ON dbo_Root
FOR EACH ROW BEGIN
  SELECT RAISE(ROLLBACK, 'delete on table "dbo_Root" violates foreign key constraint "fkd_ct_bloodbank_HospNo_dbo_Root_HospitalNumber"')
  WHERE (SELECT HospNo FROM ct_bloodbank WHERE HospNo = OLD.HospitalNumber) IS NOT NULL;
END;

-- Drop Trigger
DROP TRIGGER IF EXISTS fki_ct_haematology_HospNo_dbo_Root_HospitalNumber;

-- Foreign Key Preventing insert
CREATE TRIGGER fki_ct_haematology_HospNo_dbo_Root_HospitalNumber
BEFORE INSERT ON [ct_haematology]
FOR EACH ROW BEGIN
  SELECT RAISE(ROLLBACK, 'insert on table "ct_haematology" violates foreign key constraint "fki_ct_haematology_HospNo_dbo_Root_HospitalNumber"')
  WHERE (SELECT HospitalNumber FROM dbo_Root WHERE HospitalNumber = NEW.HospNo) IS NULL;
END;

-- Drop Trigger
DROP TRIGGER IF EXISTS fku_ct_haematology_HospNo_dbo_Root_HospitalNumber;

-- Foreign key preventing update
CREATE TRIGGER fku_ct_haematology_HospNo_dbo_Root_HospitalNumber
BEFORE UPDATE ON [ct_haematology]
FOR EACH ROW BEGIN
    SELECT RAISE(ROLLBACK, 'update on table "ct_haematology" violates foreign key constraint "fku_ct_haematology_HospNo_dbo_Root_HospitalNumber"')
      WHERE (SELECT HospitalNumber FROM dbo_Root WHERE HospitalNumber = NEW.HospNo) IS NULL;
END;

-- Drop Trigger
DROP TRIGGER IF EXISTS fkd_ct_haematology_HospNo_dbo_Root_HospitalNumber;

-- Foreign key preventing delete
CREATE TRIGGER fkd_ct_haematology_HospNo_dbo_Root_HospitalNumber
BEFORE DELETE ON dbo_Root
FOR EACH ROW BEGIN
  SELECT RAISE(ROLLBACK, 'delete on table "dbo_Root" violates foreign key constraint "fkd_ct_haematology_HospNo_dbo_Root_HospitalNumber"')
  WHERE (SELECT HospNo FROM ct_haematology WHERE HospNo = OLD.HospitalNumber) IS NOT NULL;
END;

-- Drop Trigger
DROP TRIGGER IF EXISTS fki_ct_othertests_HospNo_dbo_Root_HospitalNumber;

-- Foreign Key Preventing insert
CREATE TRIGGER fki_ct_othertests_HospNo_dbo_Root_HospitalNumber
BEFORE INSERT ON [ct_othertests]
FOR EACH ROW BEGIN
  SELECT RAISE(ROLLBACK, 'insert on table "ct_othertests" violates foreign key constraint "fki_ct_othertests_HospNo_dbo_Root_HospitalNumber"')
  WHERE (SELECT HospitalNumber FROM dbo_Root WHERE HospitalNumber = NEW.HospNo) IS NULL;
END;

-- Drop Trigger
DROP TRIGGER IF EXISTS fku_ct_othertests_HospNo_dbo_Root_HospitalNumber;

-- Foreign key preventing update
CREATE TRIGGER fku_ct_othertests_HospNo_dbo_Root_HospitalNumber
BEFORE UPDATE ON [ct_othertests]
FOR EACH ROW BEGIN
    SELECT RAISE(ROLLBACK, 'update on table "ct_othertests" violates foreign key constraint "fku_ct_othertests_HospNo_dbo_Root_HospitalNumber"')
      WHERE (SELECT HospitalNumber FROM dbo_Root WHERE HospitalNumber = NEW.HospNo) IS NULL;
END;

-- Drop Trigger
DROP TRIGGER IF EXISTS fkd_ct_othertests_HospNo_dbo_Root_HospitalNumber;

-- Foreign key preventing delete
CREATE TRIGGER fkd_ct_othertests_HospNo_dbo_Root_HospitalNumber
BEFORE DELETE ON dbo_Root
FOR EACH ROW BEGIN
  SELECT RAISE(ROLLBACK, 'delete on table "dbo_Root" violates foreign key constraint "fkd_ct_othertests_HospNo_dbo_Root_HospitalNumber"')
  WHERE (SELECT HospNo FROM ct_othertests WHERE HospNo = OLD.HospitalNumber) IS NOT NULL;
END;

-- Drop Trigger
DROP TRIGGER IF EXISTS fki_ct_virology_HospNo_dbo_Root_HospitalNumber;

-- Foreign Key Preventing insert
CREATE TRIGGER fki_ct_virology_HospNo_dbo_Root_HospitalNumber
BEFORE INSERT ON [ct_virology]
FOR EACH ROW BEGIN
  SELECT RAISE(ROLLBACK, 'insert on table "ct_virology" violates foreign key constraint "fki_ct_virology_HospNo_dbo_Root_HospitalNumber"')
  WHERE (SELECT HospitalNumber FROM dbo_Root WHERE HospitalNumber = NEW.HospNo) IS NULL;
END;

-- Drop Trigger
DROP TRIGGER IF EXISTS fku_ct_virology_HospNo_dbo_Root_HospitalNumber;

-- Foreign key preventing update
CREATE TRIGGER fku_ct_virology_HospNo_dbo_Root_HospitalNumber
BEFORE UPDATE ON [ct_virology]
FOR EACH ROW BEGIN
    SELECT RAISE(ROLLBACK, 'update on table "ct_virology" violates foreign key constraint "fku_ct_virology_HospNo_dbo_Root_HospitalNumber"')
      WHERE (SELECT HospitalNumber FROM dbo_Root WHERE HospitalNumber = NEW.HospNo) IS NULL;
END;

-- Drop Trigger
DROP TRIGGER IF EXISTS fkd_ct_virology_HospNo_dbo_Root_HospitalNumber;

-- Foreign key preventing delete
CREATE TRIGGER fkd_ct_virology_HospNo_dbo_Root_HospitalNumber
BEFORE DELETE ON dbo_Root
FOR EACH ROW BEGIN
  SELECT RAISE(ROLLBACK, 'delete on table "dbo_Root" violates foreign key constraint "fkd_ct_virology_HospNo_dbo_Root_HospitalNumber"')
  WHERE (SELECT HospNo FROM ct_virology WHERE HospNo = OLD.HospitalNumber) IS NOT NULL;
END;

-- Drop Trigger
DROP TRIGGER IF EXISTS fki_dbo_Biochemistry_HospitalNumber_dbo_Root_HospitalNumber;

-- Foreign Key Preventing insert
CREATE TRIGGER fki_dbo_Biochemistry_HospitalNumber_dbo_Root_HospitalNumber
BEFORE INSERT ON [dbo_Biochemistry]
FOR EACH ROW BEGIN
  SELECT RAISE(ROLLBACK, 'insert on table "dbo_Biochemistry" violates foreign key constraint "fki_dbo_Biochemistry_HospitalNumber_dbo_Root_HospitalNumber"')
  WHERE (SELECT HospitalNumber FROM dbo_Root WHERE HospitalNumber = NEW.HospitalNumber) IS NULL;
END;

-- Drop Trigger
DROP TRIGGER IF EXISTS fku_dbo_Biochemistry_HospitalNumber_dbo_Root_HospitalNumber;

-- Foreign key preventing update
CREATE TRIGGER fku_dbo_Biochemistry_HospitalNumber_dbo_Root_HospitalNumber
BEFORE UPDATE ON [dbo_Biochemistry]
FOR EACH ROW BEGIN
    SELECT RAISE(ROLLBACK, 'update on table "dbo_Biochemistry" violates foreign key constraint "fku_dbo_Biochemistry_HospitalNumber_dbo_Root_HospitalNumber"')
      WHERE (SELECT HospitalNumber FROM dbo_Root WHERE HospitalNumber = NEW.HospitalNumber) IS NULL;
END;

-- Drop Trigger
DROP TRIGGER IF EXISTS fkd_dbo_Biochemistry_HospitalNumber_dbo_Root_HospitalNumber;

-- Foreign key preventing delete
CREATE TRIGGER fkd_dbo_Biochemistry_HospitalNumber_dbo_Root_HospitalNumber
BEFORE DELETE ON dbo_Root
FOR EACH ROW BEGIN
  SELECT RAISE(ROLLBACK, 'delete on table "dbo_Root" violates foreign key constraint "fkd_dbo_Biochemistry_HospitalNumber_dbo_Root_HospitalNumber"')
  WHERE (SELECT HospitalNumber FROM dbo_Biochemistry WHERE HospitalNumber = OLD.HospitalNumber) IS NOT NULL;
END;

-- Drop Trigger
DROP TRIGGER IF EXISTS fki_dbo_BloodBank_HospitalNumber_dbo_Root_HospitalNumber;

-- Foreign Key Preventing insert
CREATE TRIGGER fki_dbo_BloodBank_HospitalNumber_dbo_Root_HospitalNumber
BEFORE INSERT ON [dbo_BloodBank]
FOR EACH ROW BEGIN
  SELECT RAISE(ROLLBACK, 'insert on table "dbo_BloodBank" violates foreign key constraint "fki_dbo_BloodBank_HospitalNumber_dbo_Root_HospitalNumber"')
  WHERE (SELECT HospitalNumber FROM dbo_Root WHERE HospitalNumber = NEW.HospitalNumber) IS NULL;
END;

-- Drop Trigger
DROP TRIGGER IF EXISTS fku_dbo_BloodBank_HospitalNumber_dbo_Root_HospitalNumber;

-- Foreign key preventing update
CREATE TRIGGER fku_dbo_BloodBank_HospitalNumber_dbo_Root_HospitalNumber
BEFORE UPDATE ON [dbo_BloodBank]
FOR EACH ROW BEGIN
    SELECT RAISE(ROLLBACK, 'update on table "dbo_BloodBank" violates foreign key constraint "fku_dbo_BloodBank_HospitalNumber_dbo_Root_HospitalNumber"')
      WHERE (SELECT HospitalNumber FROM dbo_Root WHERE HospitalNumber = NEW.HospitalNumber) IS NULL;
END;

-- Drop Trigger
DROP TRIGGER IF EXISTS fkd_dbo_BloodBank_HospitalNumber_dbo_Root_HospitalNumber;

-- Foreign key preventing delete
CREATE TRIGGER fkd_dbo_BloodBank_HospitalNumber_dbo_Root_HospitalNumber
BEFORE DELETE ON dbo_Root
FOR EACH ROW BEGIN
  SELECT RAISE(ROLLBACK, 'delete on table "dbo_Root" violates foreign key constraint "fkd_dbo_BloodBank_HospitalNumber_dbo_Root_HospitalNumber"')
  WHERE (SELECT HospitalNumber FROM dbo_BloodBank WHERE HospitalNumber = OLD.HospitalNumber) IS NOT NULL;
END;

-- Drop Trigger
DROP TRIGGER IF EXISTS fki_dbo_Haematology_HospitalNumber_dbo_Root_HospitalNumber;

-- Foreign Key Preventing insert
CREATE TRIGGER fki_dbo_Haematology_HospitalNumber_dbo_Root_HospitalNumber
BEFORE INSERT ON [dbo_Haematology]
FOR EACH ROW BEGIN
  SELECT RAISE(ROLLBACK, 'insert on table "dbo_Haematology" violates foreign key constraint "fki_dbo_Haematology_HospitalNumber_dbo_Root_HospitalNumber"')
  WHERE (SELECT HospitalNumber FROM dbo_Root WHERE HospitalNumber = NEW.HospitalNumber) IS NULL;
END;

-- Drop Trigger
DROP TRIGGER IF EXISTS fku_dbo_Haematology_HospitalNumber_dbo_Root_HospitalNumber;

-- Foreign key preventing update
CREATE TRIGGER fku_dbo_Haematology_HospitalNumber_dbo_Root_HospitalNumber
BEFORE UPDATE ON [dbo_Haematology]
FOR EACH ROW BEGIN
    SELECT RAISE(ROLLBACK, 'update on table "dbo_Haematology" violates foreign key constraint "fku_dbo_Haematology_HospitalNumber_dbo_Root_HospitalNumber"')
      WHERE (SELECT HospitalNumber FROM dbo_Root WHERE HospitalNumber = NEW.HospitalNumber) IS NULL;
END;

-- Drop Trigger
DROP TRIGGER IF EXISTS fkd_dbo_Haematology_HospitalNumber_dbo_Root_HospitalNumber;

-- Foreign key preventing delete
CREATE TRIGGER fkd_dbo_Haematology_HospitalNumber_dbo_Root_HospitalNumber
BEFORE DELETE ON dbo_Root
FOR EACH ROW BEGIN
  SELECT RAISE(ROLLBACK, 'delete on table "dbo_Root" violates foreign key constraint "fkd_dbo_Haematology_HospitalNumber_dbo_Root_HospitalNumber"')
  WHERE (SELECT HospitalNumber FROM dbo_Haematology WHERE HospitalNumber = OLD.HospitalNumber) IS NOT NULL;
END;

-- Drop Trigger
DROP TRIGGER IF EXISTS fki_dbo_LatestResults_dbo_Root_HospitalNumber;

-- Foreign Key Preventing insert
CREATE TRIGGER fki_dbo_LatestResults_dbo_Root_HospitalNumber
BEFORE INSERT ON [dbo_LatestResults]
FOR EACH ROW BEGIN
  SELECT RAISE(ROLLBACK, 'insert on table "dbo_LatestResults" violates foreign key constraint "fki_dbo_LatestResults_dbo_Root_HospitalNumber"')
  WHERE (SELECT HospitalNumber FROM dbo_Root WHERE HospitalNumber = NEW.HospitalNumber) IS NULL;
END;

-- Drop Trigger
DROP TRIGGER IF EXISTS fku_dbo_LatestResults_dbo_Root_HospitalNumber;

-- Foreign key preventing update
CREATE TRIGGER fku_dbo_LatestResults_dbo_Root_HospitalNumber
BEFORE UPDATE ON [dbo_LatestResults]
FOR EACH ROW BEGIN
    SELECT RAISE(ROLLBACK, 'update on table "dbo_LatestResults" violates foreign key constraint "fku_dbo_LatestResults_dbo_Root_HospitalNumber"')
      WHERE (SELECT HospitalNumber FROM dbo_Root WHERE HospitalNumber = NEW.HospitalNumber) IS NULL;
END;

-- Drop Trigger
DROP TRIGGER IF EXISTS fkd_dbo_LatestResults_dbo_Root_HospitalNumber;

-- Foreign key preventing delete
CREATE TRIGGER fkd_dbo_LatestResults_dbo_Root_HospitalNumber
BEFORE DELETE ON dbo_Root
FOR EACH ROW BEGIN
  SELECT RAISE(ROLLBACK, 'delete on table "dbo_Root" violates foreign key constraint "fkd_dbo_LatestResults_dbo_Root_HospitalNumber"')
  WHERE (SELECT HospitalNumber FROM dbo_LatestResults WHERE HospitalNumber = OLD.HospitalNumber) IS NOT NULL;
END;

-- Drop Trigger
DROP TRIGGER IF EXISTS fki_dbo_OtherTests_HospitalNumber_dbo_Root_HospitalNumber;

-- Foreign Key Preventing insert
CREATE TRIGGER fki_dbo_OtherTests_HospitalNumber_dbo_Root_HospitalNumber
BEFORE INSERT ON [dbo_OtherTests]
FOR EACH ROW BEGIN
  SELECT RAISE(ROLLBACK, 'insert on table "dbo_OtherTests" violates foreign key constraint "fki_dbo_OtherTests_HospitalNumber_dbo_Root_HospitalNumber"')
  WHERE (SELECT HospitalNumber FROM dbo_Root WHERE HospitalNumber = NEW.HospitalNumber) IS NULL;
END;

-- Drop Trigger
DROP TRIGGER IF EXISTS fku_dbo_OtherTests_HospitalNumber_dbo_Root_HospitalNumber;

-- Foreign key preventing update
CREATE TRIGGER fku_dbo_OtherTests_HospitalNumber_dbo_Root_HospitalNumber
BEFORE UPDATE ON [dbo_OtherTests]
FOR EACH ROW BEGIN
    SELECT RAISE(ROLLBACK, 'update on table "dbo_OtherTests" violates foreign key constraint "fku_dbo_OtherTests_HospitalNumber_dbo_Root_HospitalNumber"')
      WHERE (SELECT HospitalNumber FROM dbo_Root WHERE HospitalNumber = NEW.HospitalNumber) IS NULL;
END;

-- Drop Trigger
DROP TRIGGER IF EXISTS fkd_dbo_OtherTests_HospitalNumber_dbo_Root_HospitalNumber;

-- Foreign key preventing delete
CREATE TRIGGER fkd_dbo_OtherTests_HospitalNumber_dbo_Root_HospitalNumber
BEFORE DELETE ON dbo_Root
FOR EACH ROW BEGIN
  SELECT RAISE(ROLLBACK, 'delete on table "dbo_Root" violates foreign key constraint "fkd_dbo_OtherTests_HospitalNumber_dbo_Root_HospitalNumber"')
  WHERE (SELECT HospitalNumber FROM dbo_OtherTests WHERE HospitalNumber = OLD.HospitalNumber) IS NOT NULL;
END;

-- Drop Trigger
DROP TRIGGER IF EXISTS fki_dbo_Report_HospitalNumber_dbo_Root_HospitalNumber;

-- Foreign Key Preventing insert
CREATE TRIGGER fki_dbo_Report_HospitalNumber_dbo_Root_HospitalNumber
BEFORE INSERT ON [dbo_Report]
FOR EACH ROW BEGIN
  SELECT RAISE(ROLLBACK, 'insert on table "dbo_Report" violates foreign key constraint "fki_dbo_Report_HospitalNumber_dbo_Root_HospitalNumber"')
  WHERE (SELECT HospitalNumber FROM dbo_Root WHERE HospitalNumber = NEW.HospitalNumber) IS NULL;
END;

-- Drop Trigger
DROP TRIGGER IF EXISTS fku_dbo_Report_HospitalNumber_dbo_Root_HospitalNumber;

-- Foreign key preventing update
CREATE TRIGGER fku_dbo_Report_HospitalNumber_dbo_Root_HospitalNumber
BEFORE UPDATE ON [dbo_Report]
FOR EACH ROW BEGIN
    SELECT RAISE(ROLLBACK, 'update on table "dbo_Report" violates foreign key constraint "fku_dbo_Report_HospitalNumber_dbo_Root_HospitalNumber"')
      WHERE (SELECT HospitalNumber FROM dbo_Root WHERE HospitalNumber = NEW.HospitalNumber) IS NULL;
END;

-- Drop Trigger
DROP TRIGGER IF EXISTS fkd_dbo_Report_HospitalNumber_dbo_Root_HospitalNumber;

-- Foreign key preventing delete
CREATE TRIGGER fkd_dbo_Report_HospitalNumber_dbo_Root_HospitalNumber
BEFORE DELETE ON dbo_Root
FOR EACH ROW BEGIN
  SELECT RAISE(ROLLBACK, 'delete on table "dbo_Root" violates foreign key constraint "fkd_dbo_Report_HospitalNumber_dbo_Root_HospitalNumber"')
  WHERE (SELECT HospitalNumber FROM dbo_Report WHERE HospitalNumber = OLD.HospitalNumber) IS NOT NULL;
END;

-- Drop Trigger
DROP TRIGGER IF EXISTS fki_dbo_Virology_HospitalNumber_dbo_Root_HospitalNumber;

-- Foreign Key Preventing insert
CREATE TRIGGER fki_dbo_Virology_HospitalNumber_dbo_Root_HospitalNumber
BEFORE INSERT ON [dbo_Virology]
FOR EACH ROW BEGIN
  SELECT RAISE(ROLLBACK, 'insert on table "dbo_Virology" violates foreign key constraint "fki_dbo_Virology_HospitalNumber_dbo_Root_HospitalNumber"')
  WHERE (SELECT HospitalNumber FROM dbo_Root WHERE HospitalNumber = NEW.HospitalNumber) IS NULL;
END;

-- Drop Trigger
DROP TRIGGER IF EXISTS fku_dbo_Virology_HospitalNumber_dbo_Root_HospitalNumber;

-- Foreign key preventing update
CREATE TRIGGER fku_dbo_Virology_HospitalNumber_dbo_Root_HospitalNumber
BEFORE UPDATE ON [dbo_Virology]
FOR EACH ROW BEGIN
    SELECT RAISE(ROLLBACK, 'update on table "dbo_Virology" violates foreign key constraint "fku_dbo_Virology_HospitalNumber_dbo_Root_HospitalNumber"')
      WHERE (SELECT HospitalNumber FROM dbo_Root WHERE HospitalNumber = NEW.HospitalNumber) IS NULL;
END;

-- Drop Trigger
DROP TRIGGER IF EXISTS fkd_dbo_Virology_HospitalNumber_dbo_Root_HospitalNumber;

-- Foreign key preventing delete
CREATE TRIGGER fkd_dbo_Virology_HospitalNumber_dbo_Root_HospitalNumber
BEFORE DELETE ON dbo_Root
FOR EACH ROW BEGIN
  SELECT RAISE(ROLLBACK, 'delete on table "dbo_Root" violates foreign key constraint "fkd_dbo_Virology_HospitalNumber_dbo_Root_HospitalNumber"')
  WHERE (SELECT HospitalNumber FROM dbo_Virology WHERE HospitalNumber = OLD.HospitalNumber) IS NOT NULL;
END;

-- Drop Trigger
DROP TRIGGER IF EXISTS fki_exp_ct_biochem_concat_dbo_Root_HospitalNumber;

-- Foreign Key Preventing insert
CREATE TRIGGER fki_exp_ct_biochem_concat_dbo_Root_HospitalNumber
BEFORE INSERT ON [exp_ct_biochem_concat]
FOR EACH ROW BEGIN
  SELECT RAISE(ROLLBACK, 'insert on table "exp_ct_biochem_concat" violates foreign key constraint "fki_exp_ct_biochem_concat_dbo_Root_HospitalNumber"')
  WHERE (SELECT HospitalNumber FROM dbo_Root WHERE HospitalNumber = NEW.HospNo) IS NULL;
END;

-- Drop Trigger
DROP TRIGGER IF EXISTS fku_exp_ct_biochem_concat_dbo_Root_HospitalNumber;

-- Foreign key preventing update
CREATE TRIGGER fku_exp_ct_biochem_concat_dbo_Root_HospitalNumber
BEFORE UPDATE ON [exp_ct_biochem_concat]
FOR EACH ROW BEGIN
    SELECT RAISE(ROLLBACK, 'update on table "exp_ct_biochem_concat" violates foreign key constraint "fku_exp_ct_biochem_concat_dbo_Root_HospitalNumber"')
      WHERE (SELECT HospitalNumber FROM dbo_Root WHERE HospitalNumber = NEW.HospNo) IS NULL;
END;

-- Drop Trigger
DROP TRIGGER IF EXISTS fkd_exp_ct_biochem_concat_dbo_Root_HospitalNumber;

-- Foreign key preventing delete
CREATE TRIGGER fkd_exp_ct_biochem_concat_dbo_Root_HospitalNumber
BEFORE DELETE ON dbo_Root
FOR EACH ROW BEGIN
  SELECT RAISE(ROLLBACK, 'delete on table "dbo_Root" violates foreign key constraint "fkd_exp_ct_biochem_concat_dbo_Root_HospitalNumber"')
  WHERE (SELECT HospNo FROM exp_ct_biochem_concat WHERE HospNo = OLD.HospitalNumber) IS NOT NULL;
END;

-- Drop Trigger
DROP TRIGGER IF EXISTS fki_exp_ct_bloodbank_concat_dbo_Root_HospitalNumber;

-- Foreign Key Preventing insert
CREATE TRIGGER fki_exp_ct_bloodbank_concat_dbo_Root_HospitalNumber
BEFORE INSERT ON [exp_ct_bloodbank_concat]
FOR EACH ROW BEGIN
  SELECT RAISE(ROLLBACK, 'insert on table "exp_ct_bloodbank_concat" violates foreign key constraint "fki_exp_ct_bloodbank_concat_dbo_Root_HospitalNumber"')
  WHERE (SELECT HospitalNumber FROM dbo_Root WHERE HospitalNumber = NEW.HospNo) IS NULL;
END;

-- Drop Trigger
DROP TRIGGER IF EXISTS fku_exp_ct_bloodbank_concat_dbo_Root_HospitalNumber;

-- Foreign key preventing update
CREATE TRIGGER fku_exp_ct_bloodbank_concat_dbo_Root_HospitalNumber
BEFORE UPDATE ON [exp_ct_bloodbank_concat]
FOR EACH ROW BEGIN
    SELECT RAISE(ROLLBACK, 'update on table "exp_ct_bloodbank_concat" violates foreign key constraint "fku_exp_ct_bloodbank_concat_dbo_Root_HospitalNumber"')
      WHERE (SELECT HospitalNumber FROM dbo_Root WHERE HospitalNumber = NEW.HospNo) IS NULL;
END;

-- Drop Trigger
DROP TRIGGER IF EXISTS fkd_exp_ct_bloodbank_concat_dbo_Root_HospitalNumber;

-- Foreign key preventing delete
CREATE TRIGGER fkd_exp_ct_bloodbank_concat_dbo_Root_HospitalNumber
BEFORE DELETE ON dbo_Root
FOR EACH ROW BEGIN
  SELECT RAISE(ROLLBACK, 'delete on table "dbo_Root" violates foreign key constraint "fkd_exp_ct_bloodbank_concat_dbo_Root_HospitalNumber"')
  WHERE (SELECT HospNo FROM exp_ct_bloodbank_concat WHERE HospNo = OLD.HospitalNumber) IS NOT NULL;
END;

-- Drop Trigger
DROP TRIGGER IF EXISTS fki_exp_ct_haematol_concat_dbo_Root_HospitalNumber;

-- Foreign Key Preventing insert
CREATE TRIGGER fki_exp_ct_haematol_concat_dbo_Root_HospitalNumber
BEFORE INSERT ON [exp_ct_haematol_concat]
FOR EACH ROW BEGIN
  SELECT RAISE(ROLLBACK, 'insert on table "exp_ct_haematol_concat" violates foreign key constraint "fki_exp_ct_haematol_concat_dbo_Root_HospitalNumber"')
  WHERE (SELECT HospitalNumber FROM dbo_Root WHERE HospitalNumber = NEW.HospNo) IS NULL;
END;

-- Drop Trigger
DROP TRIGGER IF EXISTS fku_exp_ct_haematol_concat_dbo_Root_HospitalNumber;

-- Foreign key preventing update
CREATE TRIGGER fku_exp_ct_haematol_concat_dbo_Root_HospitalNumber
BEFORE UPDATE ON [exp_ct_haematol_concat]
FOR EACH ROW BEGIN
    SELECT RAISE(ROLLBACK, 'update on table "exp_ct_haematol_concat" violates foreign key constraint "fku_exp_ct_haematol_concat_dbo_Root_HospitalNumber"')
      WHERE (SELECT HospitalNumber FROM dbo_Root WHERE HospitalNumber = NEW.HospNo) IS NULL;
END;

-- Drop Trigger
DROP TRIGGER IF EXISTS fkd_exp_ct_haematol_concat_dbo_Root_HospitalNumber;

-- Foreign key preventing delete
CREATE TRIGGER fkd_exp_ct_haematol_concat_dbo_Root_HospitalNumber
BEFORE DELETE ON dbo_Root
FOR EACH ROW BEGIN
  SELECT RAISE(ROLLBACK, 'delete on table "dbo_Root" violates foreign key constraint "fkd_exp_ct_haematol_concat_dbo_Root_HospitalNumber"')
  WHERE (SELECT HospNo FROM exp_ct_haematol_concat WHERE HospNo = OLD.HospitalNumber) IS NOT NULL;
END;

-- Drop Trigger
DROP TRIGGER IF EXISTS fki_exp_ct_other_concat_dbo_Root_HospitalNumber;

-- Foreign Key Preventing insert
CREATE TRIGGER fki_exp_ct_other_concat_dbo_Root_HospitalNumber
BEFORE INSERT ON [exp_ct_other_concat]
FOR EACH ROW BEGIN
  SELECT RAISE(ROLLBACK, 'insert on table "exp_ct_other_concat" violates foreign key constraint "fki_exp_ct_other_concat_dbo_Root_HospitalNumber"')
  WHERE (SELECT HospitalNumber FROM dbo_Root WHERE HospitalNumber = NEW.HospNo) IS NULL;
END;

-- Drop Trigger
DROP TRIGGER IF EXISTS fku_exp_ct_other_concat_dbo_Root_HospitalNumber;

-- Foreign key preventing update
CREATE TRIGGER fku_exp_ct_other_concat_dbo_Root_HospitalNumber
BEFORE UPDATE ON [exp_ct_other_concat]
FOR EACH ROW BEGIN
    SELECT RAISE(ROLLBACK, 'update on table "exp_ct_other_concat" violates foreign key constraint "fku_exp_ct_other_concat_dbo_Root_HospitalNumber"')
      WHERE (SELECT HospitalNumber FROM dbo_Root WHERE HospitalNumber = NEW.HospNo) IS NULL;
END;

-- Drop Trigger
DROP TRIGGER IF EXISTS fkd_exp_ct_other_concat_dbo_Root_HospitalNumber;

-- Foreign key preventing delete
CREATE TRIGGER fkd_exp_ct_other_concat_dbo_Root_HospitalNumber
BEFORE DELETE ON dbo_Root
FOR EACH ROW BEGIN
  SELECT RAISE(ROLLBACK, 'delete on table "dbo_Root" violates foreign key constraint "fkd_exp_ct_other_concat_dbo_Root_HospitalNumber"')
  WHERE (SELECT HospNo FROM exp_ct_other_concat WHERE HospNo = OLD.HospitalNumber) IS NOT NULL;
END;

-- Drop Trigger
DROP TRIGGER IF EXISTS fki_exp_ct_virology_concat_dbo_Root_HospitalNumber;

-- Foreign Key Preventing insert
CREATE TRIGGER fki_exp_ct_virology_concat_dbo_Root_HospitalNumber
BEFORE INSERT ON [exp_ct_virology_concat]
FOR EACH ROW BEGIN
  SELECT RAISE(ROLLBACK, 'insert on table "exp_ct_virology_concat" violates foreign key constraint "fki_exp_ct_virology_concat_dbo_Root_HospitalNumber"')
  WHERE (SELECT HospitalNumber FROM dbo_Root WHERE HospitalNumber = NEW.HospNo) IS NULL;
END;

-- Drop Trigger
DROP TRIGGER IF EXISTS fku_exp_ct_virology_concat_dbo_Root_HospitalNumber;

-- Foreign key preventing update
CREATE TRIGGER fku_exp_ct_virology_concat_dbo_Root_HospitalNumber
BEFORE UPDATE ON [exp_ct_virology_concat]
FOR EACH ROW BEGIN
    SELECT RAISE(ROLLBACK, 'update on table "exp_ct_virology_concat" violates foreign key constraint "fku_exp_ct_virology_concat_dbo_Root_HospitalNumber"')
      WHERE (SELECT HospitalNumber FROM dbo_Root WHERE HospitalNumber = NEW.HospNo) IS NULL;
END;

-- Drop Trigger
DROP TRIGGER IF EXISTS fkd_exp_ct_virology_concat_dbo_Root_HospitalNumber;

-- Foreign key preventing delete
CREATE TRIGGER fkd_exp_ct_virology_concat_dbo_Root_HospitalNumber
BEFORE DELETE ON dbo_Root
FOR EACH ROW BEGIN
  SELECT RAISE(ROLLBACK, 'delete on table "dbo_Root" violates foreign key constraint "fkd_exp_ct_virology_concat_dbo_Root_HospitalNumber"')
  WHERE (SELECT HospNo FROM exp_ct_virology_concat WHERE HospNo = OLD.HospitalNumber) IS NOT NULL;
END;