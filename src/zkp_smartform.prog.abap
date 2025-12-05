*&---------------------------------------------------------------------*
*& Report ZKP_SMARTFORM
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zkp_smartform.

PARAMETERS: p_ebeln TYPE ekko-ebeln.

DATA: gv_fmname TYPE rs38l_fnam.

CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
  EXPORTING
    formname           = 'ZKP_DOC_PRINT'
  IMPORTING
    fm_name            = gv_fmname
  EXCEPTIONS
    no_form            = 1
    no_function_module = 2
    OTHERS             = 3.
IF sy-subrc <> 0.
  MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno

  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
ENDIF.


CALL FUNCTION gv_fmname
  EXPORTING
    iv_ebeln         = p_ebeln
  EXCEPTIONS
    formatting_error = 1
    internal_error   = 2
    send_error       = 3
    user_canceled    = 4
    OTHERS           = 5.
IF sy-subrc <> 0.
  MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno

  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
ENDIF.
