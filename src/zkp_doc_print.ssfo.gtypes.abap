TYPES: BEGIN OF ty_ekko,
         ebeln TYPE ekko-ebeln,
         aedat TYPE ekko-aedat,
         ernam TYPE ekko-ernam,
         zterm TYPE ekko-zterm,
         verkf TYPE ekko-verkf,
         telf1 TYPE ekko-telf1,
         waers TYPE ekko-waers,
         wkurs TYPE ekko-wkurs,
         bukrs TYPE ekko-bukrs,
         lifnr TYPE ekko-lifnr,
       END OF ty_ekko.

TYPES: BEGIN OF ty_t001,
         butxt TYPE t001-butxt,
         ort01 TYPE t001-ort01,
         land1 TYPE t001-land1,
       END OF ty_t001.

TYPES: BEGIN OF ty_lfa1,
         name1 TYPE lfa1-name1,
         ort01 TYPE lfa1-ort01,
         ort02 TYPE lfa1-ort02,
       END OF ty_lfa1.

TYPES: BEGIN OF ty_ekpo,
         ebelp        TYPE ekpo-ebelp,
         txz01        TYPE ekpo-txz01,
         matnr        TYPE ekpo-matnr,
         maktx        TYPE makt-maktx,
         menge        TYPE ekpo-menge,
         netpr        TYPE ekpo-netpr,
         netpr_menge  TYPE p DECIMALS 2,
         zzkp_comment TYPE ekpo-zzkp_comment,
       END OF ty_ekpo,
       tt_ekpo TYPE STANDARD TABLE OF ty_ekpo.
