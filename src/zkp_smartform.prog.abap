*&---------------------------------------------------------------------*
*& Report ZKP_SMARTFORM
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZKP_SMARTFORM.

PARAMETERS: p_ebeln TYPE ekko-ebeln.

CALL FUNCTION '/1BCDWB/SF00000487'
  EXPORTING
    iv_ebeln                   = p_ebeln
 EXCEPTIONS
   FORMATTING_ERROR           = 1
   INTERNAL_ERROR             = 2
   SEND_ERROR                 = 3
   USER_CANCELED              = 4
   OTHERS                     = 5.
IF sy-subrc <> 0.
* Implement suitable error handling here
ENDIF.
