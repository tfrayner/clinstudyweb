-- $Id$

CREATE TABLE ct_biochemistry (
  Table_ID integer(20) PRIMARY KEY NOT NULL,
  HospNo char(24),
  ResDate timestamp,
  ResTime timestamp,
  ResName char(100),
  ResValue char(150)
);
CREATE TABLE ct_bloodbank (
  Table_ID integer(20) PRIMARY KEY NOT NULL,
  HospNo char(24),
  ResDate timestamp,
  ResTime timestamp,
  ResName char(100),
  ResValue char(150)
);
CREATE TABLE ct_haematology (
  Table_ID integer(20) PRIMARY KEY NOT NULL,
  HospNo char(24),
  ResDate timestamp,
  ResTime timestamp,
  ResName char(100),
  ResValue char(150)
);
CREATE TABLE ct_othertests (
  Table_ID integer(20) PRIMARY KEY NOT NULL,
  HospNo char(24),
  ResDate timestamp,
  ResTime timestamp,
  ResName char(100),
  ResValue char(150)
);
CREATE TABLE ct_virology (
  Table_ID integer(20) PRIMARY KEY NOT NULL,
  HospNo char(24),
  ResDate timestamp,
  ResTime timestamp,
  ResName char(100),
  ResValue char(150)
);
CREATE TABLE exp_ct_biochem_concat (
  HospNo char(24),
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
  DeletedYN char(510),
  DHEAsulphate char(510),
  Ferritin char(510),
  FSH char(510),
  GFR char(510),
  Glucose char(510),
  GrowthHormone char(510),
  HbA1c char(510),
  HDL_cholesterol char(510),
  IgF char(510),
  Lactate char(510),
  LDL_cholesterol char(510),
  LH char(510),
  Lipase char(510),
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
  RowInsertDateTime char(510),
  Saturation char(510),
  Serum_Iron char(510),
  Sirolimus char(510),
  Sodium char(510),
  SpecimenID char(510),
  T3 char(510),
  T4 char(510),
  Tacrolimus char(510),
  Testosterone char(510),
  Total_CK char(510),
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
  Table_ID integer(20) PRIMARY KEY NOT NULL
);
CREATE TABLE exp_ct_bloodbank_concat (
  HospNo char(24),
  ResDate timestamp,
  ResTime timestamp,
  AntibodySpecificities1 char(510),
  AntibodySpecificities2 char(510),
  BloodGroup char(510),
  BloodTransfusions char(510),
  DeletedYN char(510),
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
  LabCodeID char(510),
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
  RowInsertDateTime char(510),
  SpecimenID char(510),
  UKTnumber char(510),
  Table_ID integer(20) PRIMARY KEY NOT NULL
);
CREATE TABLE exp_ct_haematol_concat (
  HospNo char(24),
  ResDate timestamp,
  ResTime timestamp,
  APTT char(510),
  DeletedYN char(510),
  Eosinophils char(510),
  ESR char(510),
  Haemoglobin char(510),
  INR char(510),
  Lymphocytes char(510),
  MCV char(510),
  Neutrophils char(510),
  Plts char(510),
  PT char(510),
  RowInsertDateTime char(510),
  SpecimenID char(510),
  WBC char(510),
  Table_ID integer(20) PRIMARY KEY NOT NULL
);
CREATE TABLE exp_ct_other_concat (
  HospNo char(24),
  ResDate timestamp,
  ResTime timestamp,
  AFP char(510),
  Alpha1AntiTrypsinGenotype char(510),
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
  DeletedYN char(510),
  IgA char(510),
  IgG char(510),
  IgM char(510),
  LabCodeID char(510),
  LymphocyteCount char(510),
  RheumatoidFactor char(510),
  RowInsertDateTime char(510),
  SpecimenID char(510),
  WhiteBloodCellCount char(510),
  Table_ID integer(20) PRIMARY KEY NOT NULL
);
CREATE TABLE exp_ct_virology_concat (
  HospNo char(24),
  ResDate timestamp,
  ResTime timestamp,
  Anti_HBs_post_vaccination char(510),
  CMV_IgG char(510),
  CMV_Latex char(510),
  CMV_PCR char(510),
  DeletedYN char(510),
  EBV_VCA_IgG char(510),
  HepBsAg char(510),
  HepC char(510),
  HIV char(510),
  HSV char(510),
  LabCodeID char(510),
  RowInsertDateTime char(510),
  SpecimenID char(510),
  Toxo char(510),
  VZV char(510),
  Table_ID integer(20) PRIMARY KEY NOT NULL
);
