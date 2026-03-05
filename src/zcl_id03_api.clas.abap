CLASS zcl_id03_api DEFINITION
  PUBLIC
  INHERITING FROM cl_rest_resource
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_input,
        _ext_cod    TYPE char10,
        _vend_cod   TYPE lifnr,
        _land       TYPE land1,
        _name       TYPE char70,
        _locat      TYPE ort01,
        _postal     TYPE pstlz,
        _country    TYPE regio,
        _street     TYPE stras,
        _lang       TYPE spras,
        _c_f        TYPE stcd1,
        _i_v_a      TYPE stceg,
        _physic     TYPE stkzn,
        _place      TYPE gbort,
        _date       TYPE gbdat,
        _sex        TYPE sexkz,
        _profess    TYPE profs,
        _tip_vend   TYPE char2, "ztip_forn,
        _start      TYPE dats,  "ziniz_att,
        _end        TYPE dats,  "zfine_att,
        _cond_pay   TYPE char4,  "zterm,
        _loc_rit    TYPE qland,
        _tip_inv    TYPE char2,  "zvim_inv_type,
        _tip_forn   TYPE char3,  "zvim_vend_type,
        _uff_comp   TYPE char4,  "zvim_uff_comp,
        _art62      TYPE char1,  "zvim_art_62,
        _cond_pay2  TYPE char4,  "zvim_cond_pag,
        _curr       TYPE waers,
        _min_val    TYPE minbw,
        _leadt      TYPE plifz,
        _prod_acq   TYPE char2,  "zprod_acq,
        _tip_dest   TYPE char2,  "ztip_dest,
        _qnt_min    TYPE p LENGTH 13 DECIMALS 3,  "zqtam,
        _buyer      TYPE char32,  "zbuyer1,
        _buyer2     TYPE char32,  "zbuyer2,
        _ora1       TYPE uzeit,                   "zztmfco,
        _leadt2     TYPE p LENGTH 3 DECIMALS 3,  "zzdysco,
        _ora2       TYPE uzeit,         "zztmsco,
        _gg_alert   TYPE p LENGTH 3 DECIMALS 3,  "zggalert,
        _tip_rit    TYPE witht,
        _sog_rit    TYPE wt_subjct,
        _cod_rit    TYPE wt_withcd,
        _iban       TYPE iban,
        _area_ter   TYPE char2,    "zarea_terr,
        _mail_c     TYPE char240,  "smtp_addrc,
        _mail_o     TYPE char240,  "smtp_addro,
        _mail_q     TYPE char240, "smtp_addrq,
        _mail_p_e_c TYPE char240, "smtp_addrpec,
        _tel_o      TYPE char30,  "tel_numbero,
        _tel_c      TYPE char30,  "tel_numberc,
        _tel_q      TYPE char30,  "tel_numberq,
        _cel_o      TYPE char30,  "mob_numbero,
        _cel_c      TYPE char30,  "mob_numberc,
        _cel_q      TYPE char30,  "mob_numberq,
        _g_i_v_a    TYPE char1,   "giva,
        _lib_prof   TYPE char1,   "lprof,
      END OF ty_input .
    TYPES:
      tt_input TYPE STANDARD TABLE OF ty_input .
    TYPES:
      BEGIN OF ty_output,
        _ext_cod   TYPE char10,
        _vend_cod  TYPE lifnr,
        _i_v_a     TYPE stceg,
        _c_f       TYPE stcd1,
        _status    TYPE string,
        _messaggio TYPE string,
      END OF ty_output .
    TYPES:
      tt_output TYPE STANDARD TABLE OF ty_output .
    TYPES:
      BEGIN OF ty_obbl_fields,
        fieldname   TYPE string,
        description TYPE string,
      END OF ty_obbl_fields .
    TYPES:
      tt_obbl_fields TYPE STANDARD TABLE OF ty_obbl_fields .

    METHODS if_rest_resource~post
        REDEFINITION .
    METHODS if_rest_resource~get
        REDEFINITION .
  PROTECTED SECTION.
private section.

  methods POST_MODIFICATIONS
    importing
      !IS_JSON_DATA type TY_INPUT
    exporting
      !ET_MESSAGE type TT_OUTPUT .
ENDCLASS.



CLASS ZCL_ID03_API IMPLEMENTATION.


  METHOD if_rest_resource~get.
*CALL METHOD SUPER->IF_REST_RESOURCE~GET
*    .
  ENDMETHOD.


  METHOD if_rest_resource~post.

    DATA: ls_input  TYPE ty_input,
          lt_output TYPE tt_output.

    DATA(lv_request_body) = io_entity->get_string_data( ).

    /ui2/cl_json=>deserialize(
      EXPORTING
        json             = lv_request_body                        " JSON string
        pretty_name      = /ui2/cl_json=>pretty_mode-camel_case   " Pretty Print property names
      CHANGING
        data             = ls_input                               " Data to serialize
    ).

    post_modifications(
      EXPORTING
        is_json_data = ls_input                 " JSON Data
      IMPORTING
        et_message   = lt_output                " JSON Message
    ).

    DATA(lv_output) =
      /ui2/cl_json=>serialize(
        EXPORTING
          data             = lt_output                 " Data to serialize
          pretty_name      = /ui2/cl_json=>pretty_mode-camel_case                " Pretty Print property names
      ).

    io_entity->set_string_data( iv_data = lv_output ).

  ENDMETHOD.


  METHOD post_modifications.

    DATA: ls_masters               TYPE vmds_ei_main,
          ls_master_data_correct   TYPE vmds_ei_main,
          ls_message_correct       TYPE cvis_message,
          ls_master_data_defective TYPE vmds_ei_main,
          ls_message_defective     TYPE cvis_message,
          lt_obbl_fields           TYPE tt_obbl_fields,
          ls_return                TYPE bapiret2,
          lv_error                 TYPE abap_bool.

    SELECT lifnr,
           stcd1,
           stceg
      FROM lfa1
     WHERE lifnr = @is_json_data-_vend_cod
      INTO TABLE @DATA(lt_lfa1).

    IF sy-subrc <> 0.
      APPEND VALUE #( _ext_cod   = is_json_data-_ext_cod
                      _vend_cod  = is_json_data-_vend_cod
                      _i_v_a     = is_json_data-_i_v_a
                      _c_f       = is_json_data-_c_f
                      _status    = 'Error'
                      _messaggio = 'Fornitore inesistente' ) TO et_message.

      RETURN.
    ENDIF.

    SORT lt_lfa1 BY stcd1 stceg.

    lt_obbl_fields = VALUE #( ( fieldname = '_LAND'     description = 'Paese'                 )
                              ( fieldname = '_NAME'     description = 'Nome 1'                )
                              ( fieldname = '_LOCAT'    description = 'Località'              )
                              ( fieldname = '_POSTAL'   description = 'CAP'                   )
                              ( fieldname = '_COUNTRY'  description = 'Regione'               )
                              ( fieldname = '_STREET'   description = 'Via'                   )
                              ( fieldname = '_LANG'     description = 'Lingua'                )
                              ( fieldname = '_C_F'      description = 'Codice Fiscale'        )
                              ( fieldname = '_I_V_A'    description = 'Partita IVA'           )
                              ( fieldname = '_PHYSIC'   description = 'Persona fisica'        )
                              ( fieldname = '_TIP_INV'  description = 'Tipo Fattura'          )
                              ( fieldname = '_CURR'     description = 'Divisa ordine acq.'    )
                              ( fieldname = '_TIP_DEST' description = 'Tipo di Destinazione'  )
                              ( fieldname = '_TIP_VEND' description = 'Tipologia fornitore'   )
                              ( fieldname = '_START'    description = 'Inizio Attività'       )
                              ( fieldname = '_END'      description = 'Fine Attività'         )
                              ( fieldname = '_COND_PAY' description = 'Cond. Pagamento'       )
                              ( fieldname = '_G_I_V_A'  description = 'Gruppo IVA'            )
                              ( fieldname = '_LIB_PROF' description = 'Libero Professionista' ) ).

    LOOP AT lt_obbl_fields ASSIGNING FIELD-SYMBOL(<ls_obbl_field>).

      ASSIGN COMPONENT <ls_obbl_field>-fieldname OF STRUCTURE is_json_data TO FIELD-SYMBOL(<lv_field_val>).

      IF <lv_field_val> IS INITIAL.

        APPEND VALUE #( _ext_cod    = is_json_data-_ext_cod
                        _vend_cod   = is_json_data-_vend_cod
                        _i_v_a      = is_json_data-_i_v_a
                        _c_f        = is_json_data-_c_f
                        _status     = 'Errore'
                        _messaggio  = |Campo { <ls_obbl_field>-description } Mancante| ) TO et_message.

        RETURN.

      ENDIF.

      UNASSIGN <lv_field_val>.

    ENDLOOP.

*     Rule 7
    SELECT sign,
           opti AS option,
           low,
           high
      FROM tvarvc
     WHERE name = 'ZJSON_BUKRS' " Low option of ZJSON_BUKRS
      INTO TABLE @DATA(lr_bukrs).
    IF sy-subrc = 0.
      SELECT bukrs
      FROM t001
      WHERE bukrs IN @lr_bukrs
      INTO TABLE @DATA(lt_t001).
    ENDIF.

*     Rule 9
    SELECT SINGLE low
      FROM tvarvc
     WHERE name = 'ZJSON_EKORG' " Low option of ZJSON_EKORG
      INTO @DATA(lv_ekorg).

    SELECT DISTINCT zterm,
                    zlsch
      FROM t052
      WHERE zterm = @is_json_data-_cond_pay
      INTO TABLE @DATA(lt_zlsch).

    SORT lt_zlsch BY zterm.
*     Rule 4
    READ TABLE lt_lfa1 ASSIGNING FIELD-SYMBOL(<ls_lfa1>) WITH KEY lifnr = is_json_data-_vend_cod BINARY SEARCH.

    IF sy-subrc = 0.

      IF is_json_data-_c_f <> <ls_lfa1>-stcd1.
        APPEND VALUE #( _ext_cod   = is_json_data-_ext_cod
                        _vend_cod  = is_json_data-_vend_cod
                        _i_v_a     = is_json_data-_i_v_a
                        _c_f       = is_json_data-_c_f
                        _status    = 'Error'
                        _messaggio = 'Codice Fiscale non modificabile' ) TO et_message.

        RETURN.
      ELSEIF is_json_data-_i_v_a <> <ls_lfa1>-stceg.
        APPEND VALUE #( _ext_cod   = is_json_data-_ext_cod
                        _vend_cod  = is_json_data-_vend_cod
                        _i_v_a     = is_json_data-_i_v_a
                        _c_f       = is_json_data-_c_f
                        _status    = 'Error'
                        _messaggio = 'P.IVA non modificabile' ) TO et_message.

        RETURN.
      ENDIF.

    ENDIF.
*     Rule 6
    IF is_json_data-_physic IS NOT INITIAL AND ( is_json_data-_place IS INITIAL OR is_json_data-_date IS INITIAL
    OR is_json_data-_sex IS INITIAL OR is_json_data-_profess IS INITIAL ).
      APPEND VALUE #( _ext_cod   = is_json_data-_ext_cod
                      _vend_cod  = is_json_data-_vend_cod
                      _i_v_a     = is_json_data-_i_v_a
                      _c_f       = is_json_data-_c_f
                      _status    = 'Error'
                      _messaggio = 'Persona fisica, dati mancanti' ) TO et_message.

      RETURN.
    ENDIF.

*     Rule 8
    IF is_json_data-_loc_rit IS INITIAL AND is_json_data-_lib_prof = 'S'.
      APPEND VALUE #( _ext_cod   = is_json_data-_ext_cod
                      _vend_cod  = is_json_data-_vend_cod
                      _i_v_a     = is_json_data-_i_v_a
                      _c_f       = is_json_data-_c_f
                      _status    = 'Error'
                      _messaggio = 'Libero Professionista, Paese ritenuta d’ acconto mancante' ) TO et_message.

      RETURN.
    ENDIF.
*     Rule 10
    IF ( is_json_data-_tip_rit IS INITIAL OR is_json_data-_sog_rit IS INITIAL OR is_json_data-_cod_rit IS INITIAL )
     AND is_json_data-_lib_prof = 'S' .
      APPEND VALUE #( _ext_cod   = is_json_data-_ext_cod
                      _vend_cod  = is_json_data-_vend_cod
                      _i_v_a     = is_json_data-_i_v_a
                      _c_f       = is_json_data-_c_f
                      _status    = 'Error'
                      _messaggio = 'Dati Ritenuta Mancanti' ) TO et_message.

      RETURN.
    ENDIF.
*     Rule 11
    READ TABLE lt_zlsch ASSIGNING FIELD-SYMBOL(<ls_zlsch>) WITH KEY zterm = is_json_data-_cond_pay BINARY SEARCH.
    IF sy-subrc = 0.
      IF <ls_zlsch>-zlsch = 'B' AND is_json_data-_iban IS INITIAL.
        APPEND VALUE #(  _ext_cod   = is_json_data-_ext_cod
                         _vend_cod  = is_json_data-_vend_cod
                         _i_v_a     = is_json_data-_i_v_a
                         _c_f       = is_json_data-_c_f
                         _status    = 'Error'
                         _messaggio = 'IBAN mancante per condizione pagamento bonifico' ) TO et_message.

        RETURN.
      ENDIF.
    ENDIF.

    ls_masters-vendors = VALUE #( (

      header-object_instance-lifnr = is_json_data-_vend_cod
      header-object_task           = 'U'

      central_data = VALUE #(
               address = VALUE #(
                       task   = 'U'
                       postal = VALUE #(
                              data  = VALUE #(
                                      po_ctryiso = is_json_data-_land
                                      countryiso = is_json_data-_land
                                      country    = is_json_data-_country
                                      name       = is_json_data-_name(35) " Rule 0
                                      name_2     = is_json_data-_name+35  " Rule 0
                                      city_no    = is_json_data-_locat
                                      postl_cod1 = is_json_data-_postal
                                      po_box_reg = is_json_data-_country
                                      street     = is_json_data-_street " return here to calculate street name
                                      house_no   = is_json_data-_street " return here to calculate house number
                                      title      = COND #(
                                                   WHEN is_json_data-_physic IS NOT INITIAL AND is_json_data-_sex = 1 THEN '0002'
                                                   WHEN is_json_data-_physic IS NOT INITIAL AND is_json_data-_sex = 2 THEN '0001'
                                                   ELSE '0003' )
                              )

                              datax = VALUE #(
                                      po_ctryiso = abap_true
                                      countryiso = abap_true
                                      country    = abap_true
                                      name       = abap_true
                                      name_2     = abap_true
                                      city_no    = abap_true
                                      postl_cod1 = abap_true
                                      po_box_reg = abap_true
                                      street     = abap_true
                                      house_no   = abap_true
                                      title      = abap_true
                              )
                        )
*                        Rule 13
                       communication = VALUE #(
                           smtp-smtp = VALUE #( ( contact-data-e_mail  = is_json_data-_mail_c
                                                  contact-datax-e_mail = abap_true

                                                  remark-remarks       = VALUE #( ( data-comm_notes  = 'COMMERCIALI'
                                                                                    data-langu       = is_json_data-_lang

                                                                                    datax-comm_notes = abap_true
                                                                                    datax-langu      = abap_true  ) ) )

                                                ( contact-data-e_mail  = is_json_data-_mail_o
                                                  contact-datax-e_mail = abap_true

                                                  remark-remarks       = VALUE #( ( data-comm_notes  = 'ORDINI'
                                                                                    data-langu       = is_json_data-_lang

                                                                                    datax-comm_notes = abap_true
                                                                                    datax-langu      = abap_true  ) ) )

                                                ( contact-data-e_mail  = is_json_data-_mail_q
                                                  contact-datax-e_mail = abap_true

                                                  remark-remarks       = VALUE #( ( data-comm_notes  = 'QUALITA'
                                                                                    data-langu       = is_json_data-_lang

                                                                                    datax-comm_notes = abap_true
                                                                                    datax-langu      = abap_true  ) ) )

                                                ( contact-data-e_mail  = is_json_data-_mail_p_e_c
                                                  contact-datax-e_mail = abap_true

                                                  remark-remarks       = VALUE #( ( data-comm_notes  = 'PEC'
                                                                                    data-langu       = is_json_data-_lang

                                                                                    datax-comm_notes = abap_true
                                                                                    datax-langu      = abap_true  ) ) )
                           )
*                            Rule 14 & 15
                           phone-phone = VALUE #( ( contact-data-tel_no    = is_json_data-_cel_o
                                                    contact-data-r_3_user  = '2'

                                                    contact-datax-tel_no   = abap_true
                                                    contact-datax-r_3_user = abap_true

                                                    remark-remarks         = VALUE #( ( data-comm_notes  = 'ORDINI'
                                                                                        data-langu       = is_json_data-_lang

                                                                                        datax-comm_notes = abap_true
                                                                                        datax-langu      = abap_true ) ) )

                                                  ( contact-data-tel_no    = is_json_data-_cel_c
                                                    contact-data-r_3_user  = '3'

                                                    contact-datax-tel_no   = abap_true
                                                    contact-datax-r_3_user = abap_true

                                                    remark-remarks         = VALUE #( ( data-comm_notes = 'COMMERCIALI'
                                                                                        data-langu       = is_json_data-_lang

                                                                                        datax-comm_notes = abap_true
                                                                                        datax-langu      = abap_true ) ) )

                                                  ( contact-data-tel_no    = is_json_data-_cel_q
                                                    contact-data-r_3_user  = '2'

                                                    contact-datax-tel_no   = abap_true
                                                    contact-datax-r_3_user = abap_true

                                                    remark-remarks         = VALUE #( ( data-comm_notes = 'QUALITA'
                                                                                        data-langu       = is_json_data-_lang

                                                                                        datax-comm_notes = abap_true
                                                                                        datax-langu      = abap_true ) ) )

                                                  ( contact-data-tel_no    = is_json_data-_tel_o
                                                    contact-data-r_3_user  = ''

                                                    contact-datax-tel_no   = abap_true
                                                    contact-datax-r_3_user = abap_true

                                                    remark-remarks         = VALUE #( ( data-comm_notes = 'ORDINI'
                                                                                        data-langu       = is_json_data-_lang

                                                                                        datax-comm_notes = abap_true
                                                                                        datax-langu      = abap_true ) ) )

                                                  ( contact-data-tel_no    = is_json_data-_tel_c
                                                    contact-data-r_3_user  = '1'

                                                    contact-datax-tel_no   = abap_true
                                                    contact-datax-r_3_user = abap_true

                                                    remark-remarks         = VALUE #( ( data-comm_notes = 'COMMERCIALI'
                                                                                        data-langu       = is_json_data-_lang

                                                                                        datax-comm_notes = abap_true
                                                                                        datax-langu      = abap_true ) ) )

                                                  ( contact-data-tel_no    = is_json_data-_tel_q
                                                    contact-data-r_3_user  = ''

                                                    contact-datax-tel_no   = abap_true
                                                    contact-datax-r_3_user = abap_true

                                                    remark-remarks         = VALUE #( ( data-comm_notes = 'QUALITA'
                                                                                        data-langu       = is_json_data-_lang

                                                                                        datax-comm_notes = abap_true
                                                                                        datax-langu      = abap_true ) ) )
                           )
                       )
                )
*         Rule 11
        bankdetail-bankdetails = VALUE #( ( task = 'U'

                                            data-iban       = is_json_data-_iban

                                            data_key-banks  = is_json_data-_iban(2)
                                            data_key-bankl  = is_json_data-_iban+10(5)
                                            data_key-bankn  = is_json_data-_iban+15

                                            datax-iban  = abap_true ) )
      )


      purchasing_data-purchasing = VALUE #( ( task           = 'U'

                                              data_key-ekorg = lv_ekorg

                                              data-waers     = is_json_data-_curr
                                              data-minbw     = is_json_data-_min_val
                                              data-plifz     = is_json_data-_leadt

                                              datax-waers    = abap_true
                                              datax-minbw    = abap_true
                                              datax-plifz    = abap_true )
                                          )

    ) ).

    READ TABLE ls_masters-vendors ASSIGNING FIELD-SYMBOL(<ls_vendor>) INDEX 1.

    IF sy-subrc = 0.

      LOOP AT lt_t001 ASSIGNING FIELD-SYMBOL(<ls_t001>).


        APPEND VALUE #( task = 'I'

                        data_key = VALUE #( bukrs = <ls_t001>-bukrs     )

                        data = VALUE #( zterm = is_json_data-_cond_pay
                                        qland = is_json_data-_loc_rit
                                        guzte = is_json_data-_cond_pay
                                        zuawa = 'Z02'
                                        akont = '0024070001'
                                        fdgrv = 'ZF01'
                                        reprf = 'X'                     )

                        datax = VALUE #( zterm = abap_true
                                         qland = abap_true
                                         guzte = abap_true
                                         zuawa = abap_true
                                         akont = abap_true
                                         fdgrv = abap_true
                                         reprf = abap_true              )

                        wtax_type-wtax_type = VALUE #( ( task = 'I'

                                                         data_key = VALUE #( witht     = is_json_data-_tip_rit )

                                                         data     = VALUE #( wt_subjct = is_json_data-_sog_rit
                                                                             wt_withcd = is_json_data-_cod_rit )

                                                         datax    = VALUE #( wt_subjct = abap_true
                                                                             wt_withcd = abap_true             )
                                                      ) )
                       ) TO <ls_vendor>-company_data-company.

      ENDLOOP.

    ENDIF.

    vmd_ei_api=>maintain_bapi(
      EXPORTING
        is_master_data           = ls_masters                               " Vendor Total Data
      IMPORTING
        es_master_data_correct   = ls_master_data_correct                   " Vendor Total Data Without Errors
        es_message_correct       = ls_message_correct                       " Error Indicator and System Messages for Data Without Errors
        es_master_data_defective = ls_master_data_defective                 " Vendor Total Data with Errors
        es_message_defective     = ls_message_defective                     " Error Indicator and System Messages for Incorrect Data
    ).

    CLEAR lv_error.

    LOOP AT ls_message_defective-messages ASSIGNING FIELD-SYMBOL(<ls_message>).

      IF <ls_message>-type CS 'E' OR <ls_message>-type CS 'A'.

        lv_error = abap_true.

      ENDIF.

    ENDLOOP.

    IF lv_error IS NOT INITIAL.

      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      RETURN.

    ENDIF.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait   = abap_true
      IMPORTING
        return = ls_return.

    READ TABLE ls_master_data_correct-vendors ASSIGNING <ls_vendor> INDEX 1.

    IF sy-subrc = 0.

      APPEND VALUE #( _ext_cod    = is_json_data-_ext_cod
                      _vend_cod   = <ls_vendor>-header-object_instance-lifnr
                      _i_v_a      = is_json_data-_i_v_a
                      _c_f        = is_json_data-_c_f
                      _status     = 'Success'
                      _messaggio  = 'Fornitore modificato correttamente' ) TO et_message.

    ENDIF.

  ENDMETHOD.
ENDCLASS.
