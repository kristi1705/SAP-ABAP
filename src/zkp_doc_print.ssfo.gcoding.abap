SELECT SINGLE ebeln
              aedat
              ernam
              zterm
              verkf
              telf1
              waers
              wkurs
              bukrs
              lifnr
FROM ekko
INTO gs_ekko
WHERE ebeln = iv_ebeln.

SELECT SINGLE butxt
              ort01
              land1
  FROM t001
  INTO gs_t001
  WHERE bukrs = gs_ekko-bukrs.

SELECT SINGLE name1
              ort01
              ort02
  FROM lfa1
  INTO gs_lfa1
  WHERE lifnr = gs_ekko-lifnr.

SELECT ekpo~ebelp
       ekpo~txz01
       ekpo~matnr
       makt~maktx
       ekpo~menge
       ekpo~netpr
       ekpo~zzkp_comment
 FROM ekpo
  LEFT JOIN makt ON makt~matnr = ekpo~matnr
  AND makt~spras = sy-langu
  INTO CORRESPONDING FIELDS OF TABLE gt_ekpo
  WHERE ebeln = iv_ebeln.

LOOP AT gt_ekpo INTO gs_ekpo.

  gs_ekpo-netpr_menge = gs_ekpo-netpr * gs_ekpo-menge.
  MODIFY gt_ekpo FROM gs_ekpo TRANSPORTING netpr_menge.

ENDLOOP.

gv_ebeln = iv_ebeln.

CALL FUNCTION 'READ_TEXT'
  EXPORTING
    id                      = 'F01'
    language                = sy-langu
    name                    = gv_ebeln
    object                  = 'EKKO'
  TABLES
    lines                   = gt_tline
  EXCEPTIONS
    id                      = 1
    language                = 2
    name                    = 3
    not_found               = 4
    object                  = 5
    reference_check         = 6
    wrong_access_to_archive = 7
    OTHERS                  = 8.
