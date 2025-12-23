*&---------------------------------------------------------------------*
*& Report ZKP_INCREASE_PERFORMANCE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zkp_increase_performance.

DATA: it_keko TYPE STANDARD TABLE OF keko,
      wa_keko LIKE LINE OF it_keko,
      it_keph TYPE STANDARD TABLE OF keph,
      wa_keph LIKE LINE OF it_keph.
DATA: d_mat_cost   TYPE keph-kst001,
      d_lab_cost   TYPE keph-kst004,
      d_over_head  TYPE keph-kst010,
      d_ext_purch  TYPE keph-kst014,
      d_misc_cost  TYPE keph-kst002,
      ld_starttime TYPE i,
      ld_endtime   TYPE i,
      ld_runtime   TYPE i.

START-OF-SELECTION.
  SELECT *
  INTO TABLE it_keko FROM keko.

  SELECT *
  INTO TABLE it_keph FROM keph.

  SORT it_keph BY kalnr kalka bwvar kadky.

  PERFORM get_cost_values.
*----------------------------------------------------------------------*
FORM get_cost_values.

  GET RUN TIME FIELD ld_starttime.

  LOOP AT it_keko ASSIGNING FIELD-SYMBOL(<ls_keko>).

    CLEAR:d_mat_cost, d_lab_cost, d_over_head, d_ext_purch,d_misc_cost.

    READ TABLE it_keph TRANSPORTING NO FIELDS WITH KEY kalnr = <ls_keko>-kalnr
                                             kalka = <ls_keko>-kalka
                                             bwvar = <ls_keko>-bwvar
                                             kadky = <ls_keko>-kadky BINARY SEARCH.

    IF sy-subrc = 0.

      LOOP AT it_keph ASSIGNING FIELD-SYMBOL(<ls_keph>) FROM sy-tabix.

        IF <ls_keph>-kalnr <> <ls_keko>-kalnr
        OR <ls_keph>-kalka <> <ls_keko>-kalka
        OR <ls_keph>-bwvar <> <ls_keko>-bwvar
        OR <ls_keph>-kadky <> <ls_keko>-kadky.

          EXIT.

        ENDIF.

        d_mat_cost = d_mat_cost + <ls_keph>-kst001.
        d_lab_cost = d_lab_cost + <ls_keph>-kst004.
        d_over_head = d_over_head + <ls_keph>-kst010.
        d_ext_purch = d_ext_purch + <ls_keph>-kst014.
        d_misc_cost = d_misc_cost + <ls_keph>-kst002 + <ls_keph>-kst003
                    + <ls_keph>-kst005 + <ls_keph>-kst006 + <ls_keph>-kst007
                    + <ls_keph>-kst008 + <ls_keph>-kst009 + <ls_keph>-kst011
                    + <ls_keph>-kst012 + <ls_keph>-kst013 + <ls_keph>-kst015
                    + <ls_keph>-kst016 + <ls_keph>-kst017 + <ls_keph>-kst018
                    + <ls_keph>-kst019 + <ls_keph>-kst020 + <ls_keph>-kst021
                    + <ls_keph>-kst022 + <ls_keph>-kst023 + <ls_keph>-kst024
                    + <ls_keph>-kst025 + <ls_keph>-kst026 + <ls_keph>-kst027
                    + <ls_keph>-kst028 + <ls_keph>-kst029 + <ls_keph>-kst030
                    + <ls_keph>-kst031 + <ls_keph>-kst032 + <ls_keph>-kst033
                    + <ls_keph>-kst034 + <ls_keph>-kst035 + <ls_keph>-kst036
                    + <ls_keph>-kst037 + <ls_keph>-kst038 + <ls_keph>-kst039
                    + <ls_keph>-kst040.
      ENDLOOP.

    ENDIF.

    IF wa_keko-losgr GE 1.
      d_mat_cost  = d_mat_cost  / <ls_keko>-losgr.
      d_lab_cost  = d_lab_cost  / <ls_keko>-losgr.
      d_over_head = d_over_head / <ls_keko>-losgr.
      d_ext_purch = d_ext_purch / <ls_keko>-losgr.
      d_misc_cost = d_misc_cost / <ls_keko>-losgr.
    ENDIF.

    CHECK NOT d_mat_cost IS INITIAL.
    WRITE:/ d_mat_cost, d_lab_cost, d_over_head, d_ext_purch,d_misc_cost.

  ENDLOOP.

  GET RUN TIME FIELD ld_endtime.
  ld_runtime = ld_endtime - ld_starttime.

  WRITE:/ ld_runtime, 'micro, nano or what ever seconds'.

  ld_runtime =  ld_runtime / 1000000.
  WRITE:/ ld_runtime, 'seconds'.

ENDFORM.

*ORIGINAL CODE TO BE IMPROVED

*FORM get_cost_values.
*  GET RUN TIME FIELD ld_starttime.
*  LOOP AT it_keko INTO wa_keko.
*    CLEAR:d_mat_cost, d_lab_cost, d_over_head, d_ext_purch,d_misc_cost.
*    LOOP AT it_keph INTO wa_keph WHERE kalnr = wa_keko-kalnr
*                                   AND kalka = wa_keko-kalka
*                                   AND bwvar = wa_keko-bwvar
*                                   AND kadky = wa_keko-kadky.
**       Key match
*      d_mat_cost = d_mat_cost + wa_keph-kst001.
*      d_lab_cost = d_lab_cost + wa_keph-kst004.
*      d_over_head = d_over_head + wa_keph-kst010.
*      d_ext_purch = d_ext_purch + wa_keph-kst014.
*      d_misc_cost = d_misc_cost + wa_keph-kst002 + wa_keph-kst003
*                  + wa_keph-kst005 + wa_keph-kst006 + wa_keph-kst007
*                  + wa_keph-kst008 + wa_keph-kst009 + wa_keph-kst011
*                  + wa_keph-kst012 + wa_keph-kst013 + wa_keph-kst015
*                  + wa_keph-kst016 + wa_keph-kst017 + wa_keph-kst018
*                  + wa_keph-kst019 + wa_keph-kst020 + wa_keph-kst021
*                  + wa_keph-kst022 + wa_keph-kst023 + wa_keph-kst024
*                  + wa_keph-kst025 + wa_keph-kst026 + wa_keph-kst027
*                  + wa_keph-kst028 + wa_keph-kst029 + wa_keph-kst030
*                  + wa_keph-kst031 + wa_keph-kst032 + wa_keph-kst033
*                  + wa_keph-kst034 + wa_keph-kst035 + wa_keph-kst036
*                  + wa_keph-kst037 + wa_keph-kst038 + wa_keph-kst039
*                  + wa_keph-kst040.
*    ENDLOOP.
*    IF wa_keko-losgr GE 1.
*      d_mat_cost  = d_mat_cost  / wa_keko-losgr.
*      d_lab_cost  = d_lab_cost  / wa_keko-losgr.
*      d_over_head = d_over_head / wa_keko-losgr.
*      d_ext_purch = d_ext_purch / wa_keko-losgr.
*      d_misc_cost = d_misc_cost / wa_keko-losgr.
*    ENDIF.
*    CHECK NOT d_mat_cost IS INITIAL.
*    WRITE:/ d_mat_cost, d_lab_cost, d_over_head, d_ext_purch,d_misc_cost.
*  ENDLOOP.
*  GET RUN TIME FIELD ld_endtime.
*  ld_runtime = ld_endtime - ld_starttime. "time in micro seconds
*  WRITE:/ ld_runtime, 'micro, nano or what ever seconds'.
*  ld_runtime =  ld_runtime / 1000000.        "time in seconds
*  WRITE:/ ld_runtime, 'seconds'.
*ENDFORM.                               " GET_COST_VALUES
