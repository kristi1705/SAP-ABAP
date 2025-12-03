*&---------------------------------------------------------------------*
*& Report ZKP_SAPSCRIPT_DRIVER_PROG
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zkp_sapscript_driver_prog.

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
         meins        TYPE ekpo-meins,
       END OF ty_ekpo,
       tt_ekpo TYPE STANDARD TABLE OF ty_ekpo.

TYPES: BEGIN OF ty_output,
         ebelp        TYPE string,
         txz01        TYPE string,
         matnr        TYPE string,
         maktx        TYPE string,
         menge(20)    TYPE c,
         netpr        TYPE string,
         netpr_menge  TYPE string,
         zzkp_comment TYPE string,
         new_row      TYPE abap_bool,
       END OF ty_output,
       tt_output TYPE STANDARD TABLE OF ty_output.

TYPES: BEGIN OF ty_header,
         ebelp        TYPE c LENGTH 20,
         txz01        TYPE c LENGTH 20,
         matnr        TYPE c LENGTH 20,
         maktx        TYPE c LENGTH 20,
         menge        TYPE c LENGTH 20,
         netpr        TYPE c LENGTH 20,
         netpr_menge  TYPE c LENGTH 20,
         zzkp_comment TYPE c LENGTH 20,
       END OF ty_header,
       tt_header TYPE STANDARD TABLE OF ty_header.

DATA: gt_tline  TYPE STANDARD TABLE OF tline,
      gt_header TYPE tt_header,
      gs_header TYPE ty_header,
      gs_t001   TYPE ty_t001,
      gs_ekko   TYPE ty_ekko,
      gs_lfa1   TYPE ty_lfa1,
      gs_ekpo   TYPE ty_ekpo,
      gt_ekpo   TYPE tt_ekpo,
      gt_output TYPE tt_output,
      gs_output TYPE ty_output,
      gv_total  TYPE ekpo-netpr,
      gs_tline  TYPE tline,
      gs_lines  TYPE tline,
      gv_ebeln  TYPE thead-tdname,
      gv_height TYPE i.

DATA BEGIN OF gs_options.
INCLUDE STRUCTURE itcpo.
DATA END OF gs_options.

PARAMETERS: p_ebeln TYPE ekko-ebeln.

START-OF-SELECTION.

  PERFORM get_data.

  CLEAR gs_options.
  gs_options-tddest = '*'.
  gs_options-tdimmed = '*'.
  gs_options-tddelete = '*'.
  gs_options-tdnewid = 'X'.

  CALL FUNCTION 'OPEN_FORM'
    EXPORTING
      application                 = 'TX'
      device                      = 'PRINTER'
      dialog                      = 'X'
      form                        = 'ZKP_SAPSCRIPT'
      language                    = sy-langu
      options                     = gs_options
    EXCEPTIONS
      canceled                    = 1
      device                      = 2
      form                        = 3
      options                     = 4
      unclosed                    = 5
      mail_options                = 6
      archive_error               = 7
      invalid_fax_number          = 8
      more_params_needed_in_batch = 9
      spool_error                 = 10
      codepage                    = 11
      OTHERS                      = 12.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element                  = 'TABLE_HEADER'
      function                 = 'SET'
      type                     = 'BODY'
      window                   = 'MAIN'
    EXCEPTIONS
      element                  = 1
      function                 = 2
      type                     = 3
      unopened                 = 4
      unstarted                = 5
      window                   = 6
      bad_pageformat_for_print = 7
      spool_error              = 8
      codepage                 = 9
      OTHERS                   = 10.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  PERFORM table_header.

  PERFORM table_cells.

  CALL FUNCTION 'CLOSE_FORM'
    EXCEPTIONS
      unopened                 = 1
      bad_pageformat_for_print = 2
      send_error               = 3
      spool_error              = 4
      codepage                 = 5
      OTHERS                   = 6.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

END-OF-SELECTION.

FORM get_data.

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
  WHERE ebeln = p_ebeln.

  SELECT SINGLE butxt
                ort01
                land1
    FROM t001
    INTO gs_t001
    WHERE bukrs = gs_ekko-bukrs
    AND   spras = sy-langu.

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
         ekpo~meins
    FROM ekpo
    LEFT JOIN makt
    ON makt~matnr = ekpo~matnr
    AND makt~spras = sy-langu
    INTO CORRESPONDING FIELDS OF TABLE gt_ekpo
    WHERE ekpo~ebeln = p_ebeln.

  LOOP AT gt_ekpo INTO gs_ekpo.

    gs_ekpo-netpr_menge = gs_ekpo-netpr * gs_ekpo-menge.

    MODIFY gt_ekpo FROM gs_ekpo INDEX sy-tabix TRANSPORTING netpr_menge.

  ENDLOOP.

ENDFORM.

FORM table_header.

  gt_header = VALUE #( ( ebelp = 'Item' txz01 = 'Description' matnr = 'Material' maktx = 'Material' menge = 'Quantity' netpr = 'Net' netpr_menge = 'Net' zzkp_comment = 'Comment' )
                         ( maktx = 'Descr.' netpr = 'Price' netpr_menge = 'Value' ) ).

  LOOP AT gt_header INTO gs_header.

    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element                  = 'TABLE_COLUMNS'
        function                 = 'SET'
        type                     = 'BODY'
        window                   = 'MAIN'
      EXCEPTIONS
        element                  = 1
        function                 = 2
        type                     = 3
        unopened                 = 4
        unstarted                = 5
        window                   = 6
        bad_pageformat_for_print = 7
        spool_error              = 8
        codepage                 = 9
        OTHERS                   = 10.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

  ENDLOOP.

ENDFORM.

FORM table_cells.

  DATA: lv_max_rows     TYPE i,
        lv_index        TYPE i,
        lv_tabix        TYPE i,
        lv_ypos         TYPE p DECIMALS 2,
        lv_height       TYPE p DECIMALS 2,
        lv_cmd          TYPE string,
        lv_win_height   TYPE p DECIMALS 1,
        lt_lines        TYPE TABLE OF swastrtab,
        lv_display_line TYPE i.

  lv_ypos = 10.
  lv_win_height = '126.2'.

  MOVE-CORRESPONDING gt_ekpo TO gt_output.

  LOOP AT gt_output INTO gs_output WHERE ebelp IS NOT INITIAL.

    lv_display_line = sy-tabix.
    lv_tabix = sy-tabix.
    DATA(lv_ebelp) = gs_output-ebelp.

    CALL FUNCTION 'SWA_STRING_SPLIT'
      EXPORTING
        input_string         = gs_output-txz01
        max_component_length = 8
      TABLES
        string_components    = lt_lines.
    IF sy-subrc = 0.

      DATA(lv_rows) = lines( lt_lines ).

      IF lv_max_rows IS INITIAL.
        lv_max_rows = lv_rows.
      ENDIF.

      lv_rows = lines( lt_lines ).

      IF lv_max_rows < lv_rows.

        lv_max_rows = lv_rows.

      ENDIF.

      IF lv_rows = 1.

        CLEAR lt_lines.

      ELSE.

        lv_index = 1.

        LOOP AT lt_lines INTO DATA(ls_lines).

          IF sy-tabix  = 1.

            CLEAR gs_output.
            gs_output-txz01 = ls_lines-str.
            MODIFY gt_output FROM gs_output INDEX lv_tabix TRANSPORTING txz01.

            CONTINUE.

          ENDIF.

          READ TABLE gt_output INTO gs_output INDEX lv_tabix + lv_index.

          IF sy-subrc <> 0.

            CLEAR gs_output.
            gs_output-txz01 = ls_lines-str.
            gs_output-new_row = abap_true.
            INSERT gs_output INTO gt_output INDEX lv_tabix + lv_index.

          ELSE.

            IF gs_output-new_row = abap_false AND gs_output-ebelp <> lv_ebelp.

              CLEAR gs_output.
              gs_output-txz01 = ls_lines-str.
              gs_output-new_row = abap_true.
              INSERT gs_output INTO gt_output INDEX lv_tabix + lv_index.

            ELSEIF gs_output-new_row = abap_true.

              CLEAR gs_output.
              gs_output-txz01 = ls_lines-str.
              MODIFY gt_output FROM gs_output INDEX lv_tabix + lv_index TRANSPORTING txz01.

            ENDIF.

          ENDIF.

          lv_index += 1.

        ENDLOOP.

      ENDIF.

      CLEAR: lv_rows, lt_lines, ls_lines, gs_output.

      lv_index = 0.

    ENDIF.

    READ TABLE gt_output INTO gs_output INDEX lv_tabix.

    CALL FUNCTION 'SWA_STRING_SPLIT'
      EXPORTING
        input_string         = gs_output-matnr
        max_component_length = 6
      TABLES
        string_components    = lt_lines.
    IF sy-subrc = 0.

      lv_rows = lines( lt_lines ).

      IF lv_max_rows IS INITIAL.
        lv_max_rows = lv_rows.
      ENDIF.

      lv_rows = lines( lt_lines ).

      IF lv_max_rows < lv_rows.

        lv_max_rows = lv_rows.

      ENDIF.

      IF lv_rows = 1.

        CLEAR lt_lines.

      ELSE.

        lv_index = 1.

        LOOP AT lt_lines INTO ls_lines.

          IF sy-tabix  = 1.

            CLEAR gs_output.
            gs_output-matnr = ls_lines-str.
            MODIFY gt_output FROM gs_output INDEX lv_tabix TRANSPORTING matnr.

            CONTINUE.

          ENDIF.

          READ TABLE gt_output INTO gs_output INDEX lv_tabix + lv_index.

          IF sy-subrc <> 0.

            CLEAR gs_output.
            gs_output-matnr = ls_lines-str.
            gs_output-new_row = abap_true.
            INSERT gs_output INTO gt_output INDEX lv_tabix + lv_index.

          ELSE.

            IF gs_output-new_row = abap_false AND gs_output-ebelp <> lv_ebelp.

              CLEAR gs_output.
              gs_output-matnr = ls_lines-str.
              gs_output-new_row = abap_true.
              INSERT gs_output INTO gt_output INDEX lv_tabix + lv_index.

            ELSEIF gs_output-new_row = abap_true.

              CLEAR gs_output.
              gs_output-matnr = ls_lines-str.
              MODIFY gt_output FROM gs_output INDEX lv_tabix + lv_index TRANSPORTING matnr.

            ENDIF.

          ENDIF.

          lv_index += 1.

        ENDLOOP.

      ENDIF.

      CLEAR: lv_rows, lt_lines, ls_lines, gs_output.

      lv_index = 0.

    ENDIF.

    READ TABLE gt_output INTO gs_output INDEX lv_tabix.

    CALL FUNCTION 'SWA_STRING_SPLIT'
      EXPORTING
        input_string         = gs_output-maktx
        max_component_length = 8
      TABLES
        string_components    = lt_lines.
    IF sy-subrc = 0.

      lv_rows = lines( lt_lines ).

      IF lv_max_rows IS INITIAL.
        lv_max_rows = lv_rows.
      ENDIF.

      lv_rows = lines( lt_lines ).

      IF lv_max_rows < lv_rows.

        lv_max_rows = lv_rows.

      ENDIF.

      IF lv_rows = 1.

        CLEAR lt_lines.

      ELSE.

        lv_index = 1.

        LOOP AT lt_lines INTO ls_lines.

          IF sy-tabix  = 1.

            CLEAR gs_output.
            gs_output-maktx = ls_lines-str.
            MODIFY gt_output FROM gs_output INDEX lv_tabix TRANSPORTING maktx.

            CONTINUE.

          ENDIF.

          READ TABLE gt_output INTO gs_output INDEX lv_tabix + lv_index.

          IF sy-subrc <> 0.

            CLEAR gs_output.
            gs_output-maktx = ls_lines-str.
            gs_output-new_row = abap_true.
            INSERT gs_output INTO gt_output INDEX lv_tabix + lv_index.

          ELSE.

            IF gs_output-new_row = abap_false AND gs_output-ebelp <> lv_ebelp.

              CLEAR gs_output.
              gs_output-maktx = ls_lines-str.
              gs_output-new_row = abap_true.
              INSERT gs_output INTO gt_output INDEX lv_tabix + lv_index.

            ELSEIF gs_output-new_row = abap_true.

              CLEAR gs_output.
              gs_output-maktx = ls_lines-str.
              MODIFY gt_output FROM gs_output INDEX lv_tabix + lv_index TRANSPORTING maktx.

            ENDIF.

          ENDIF.

          lv_index += 1.

        ENDLOOP.

      ENDIF.

      CLEAR: lv_rows, lt_lines, ls_lines, gs_output.

      lv_index = 0.

    ENDIF.

    READ TABLE gt_output INTO gs_output INDEX lv_tabix.

    CALL FUNCTION 'SWA_STRING_SPLIT'
      EXPORTING
        input_string         = gs_output-zzkp_comment
        max_component_length = 6
      TABLES
        string_components    = lt_lines.
    IF sy-subrc = 0.

      lv_rows = lines( lt_lines ).

      IF lv_max_rows IS INITIAL.
        lv_max_rows = lv_rows.
      ENDIF.

      lv_rows = lines( lt_lines ).

      IF lv_max_rows < lv_rows.

        lv_max_rows = lv_rows.

      ENDIF.

      IF lv_rows = 1.

        CLEAR lt_lines.

      ELSE.

        lv_index = 1.

        LOOP AT lt_lines INTO ls_lines.

          IF sy-tabix  = 1.

            CLEAR gs_output.
            gs_output-zzkp_comment = ls_lines-str.
            MODIFY gt_output FROM gs_output INDEX lv_tabix TRANSPORTING zzkp_comment.

            CONTINUE.

          ENDIF.

          READ TABLE gt_output INTO gs_output INDEX lv_tabix + lv_index.

          IF sy-subrc <> 0.

            CLEAR gs_output.
            gs_output-zzkp_comment = ls_lines-str.
            gs_output-new_row = abap_true.
            INSERT gs_output INTO gt_output INDEX lv_tabix + lv_index.

          ELSE.

            IF gs_output-new_row = abap_false AND gs_output-ebelp <> lv_ebelp.

              CLEAR gs_output.
              gs_output-zzkp_comment = ls_lines-str.
              gs_output-new_row = abap_true.
              INSERT gs_output INTO gt_output INDEX lv_tabix + lv_index.

            ELSEIF gs_output-new_row = abap_true.

              CLEAR gs_output.
              gs_output-zzkp_comment = ls_lines-str.
              MODIFY gt_output FROM gs_output INDEX lv_tabix + lv_index TRANSPORTING zzkp_comment.

            ENDIF.

          ENDIF.

          lv_index += 1.

        ENDLOOP.

      ENDIF.

      CLEAR: lv_rows, lt_lines, ls_lines, gs_output.

      lv_index = 0.

    ENDIF.

    lv_height = '5.23' * lv_max_rows.

    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element  = 'TABLE_CELLS'
        function = 'APPEND'
        type     = 'BODY'
        window   = 'MAIN'
      EXCEPTIONS
        OTHERS   = 10.

    IF lv_ypos + lv_height <= lv_win_height.

      lv_cmd = |BOX XPOS '0' MM YPOS '{ lv_ypos }' MM WIDTH '15' MM HEIGHT '{ lv_height }' MM FRAME 01 TW|.
      CALL FUNCTION 'CONTROL_FORM'
        EXPORTING
          command = lv_cmd
        EXCEPTIONS
          OTHERS  = 1.

      lv_cmd = |BOX XPOS '15' MM YPOS '{ lv_ypos }' MM WIDTH '20' MM HEIGHT '{ lv_height }' MM FRAME 01 TW|.
      CALL FUNCTION 'CONTROL_FORM'
        EXPORTING
          command = lv_cmd
        EXCEPTIONS
          OTHERS  = 1.

      lv_cmd = |BOX XPOS '35' MM YPOS '{ lv_ypos }' MM WIDTH '17.5' MM HEIGHT '{ lv_height }' MM FRAME 01 TW|.
      CALL FUNCTION 'CONTROL_FORM'
        EXPORTING
          command = lv_cmd
        EXCEPTIONS
          OTHERS  = 1.

      lv_cmd = |BOX XPOS '52.5' MM YPOS '{ lv_ypos }' MM WIDTH '20' MM HEIGHT '{ lv_height }' MM FRAME 01 TW|.
      CALL FUNCTION 'CONTROL_FORM'
        EXPORTING
          command = lv_cmd
        EXCEPTIONS
          OTHERS  = 1.

      lv_cmd = |BOX XPOS '72.5' MM YPOS '{ lv_ypos }' MM WIDTH '26' MM HEIGHT '{ lv_height }' MM FRAME 01 TW|.
      CALL FUNCTION 'CONTROL_FORM'
        EXPORTING
          command = lv_cmd
        EXCEPTIONS
          OTHERS  = 1.

      lv_cmd = |BOX XPOS '98.5' MM YPOS '{ lv_ypos }' MM WIDTH '25.5' MM HEIGHT '{ lv_height }' MM FRAME 01 TW|.
      CALL FUNCTION 'CONTROL_FORM'
        EXPORTING
          command = lv_cmd
        EXCEPTIONS
          OTHERS  = 1.

      lv_cmd = |BOX XPOS '124' MM YPOS '{ lv_ypos }' MM WIDTH '30.2' MM HEIGHT '{ lv_height }' MM FRAME 01 TW|.
      CALL FUNCTION 'CONTROL_FORM'
        EXPORTING
          command = lv_cmd
        EXCEPTIONS
          OTHERS  = 1.

      lv_cmd = |BOX XPOS '154.2' MM YPOS '{ lv_ypos }' MM WIDTH '20' MM HEIGHT '{ lv_height }' MM FRAME 01 TW|.
      CALL FUNCTION 'CONTROL_FORM'
        EXPORTING
          command = lv_cmd
        EXCEPTIONS
          OTHERS  = 1.

      DO lv_max_rows TIMES.

        READ TABLE gt_output INTO gs_output INDEX lv_display_line.

        IF gs_output-ebelp IS NOT INITIAL.

          READ TABLE gt_ekpo INTO gs_ekpo INDEX lv_display_line.
          WRITE gs_ekpo-menge UNIT gs_ekpo-meins TO gs_output-menge.

        ENDIF.

        CALL FUNCTION 'WRITE_FORM'
          EXPORTING
            element  = 'TABLE_VALUES'
            function = 'SET'
            type     = 'BODY'
            window   = 'MAIN'
          EXCEPTIONS
            OTHERS   = 10.

        lv_display_line += 1.

      ENDDO.

      lv_ypos += lv_height.

    ELSE.

      lv_win_height = '216.2'.

      CALL FUNCTION 'CONTROL_FORM'
        EXPORTING
          command = 'NEW-PAGE'.

      lv_ypos = 0.

      lv_cmd = |BOX XPOS '0' MM YPOS '{ lv_ypos }' MM WIDTH '15' MM HEIGHT '{ lv_height }' MM FRAME 01 TW|.
      CALL FUNCTION 'CONTROL_FORM'
        EXPORTING
          command = lv_cmd
        EXCEPTIONS
          OTHERS  = 1.

      lv_cmd = |BOX XPOS '15' MM YPOS '{ lv_ypos }' MM WIDTH '20' MM HEIGHT '{ lv_height }' MM FRAME 01 TW|.
      CALL FUNCTION 'CONTROL_FORM'
        EXPORTING
          command = lv_cmd
        EXCEPTIONS
          OTHERS  = 1.

      lv_cmd = |BOX XPOS '35' MM YPOS '{ lv_ypos }' MM WIDTH '17.5' MM HEIGHT '{ lv_height }' MM FRAME 01 TW|.
      CALL FUNCTION 'CONTROL_FORM'
        EXPORTING
          command = lv_cmd
        EXCEPTIONS
          OTHERS  = 1.

      lv_cmd = |BOX XPOS '52.5' MM YPOS '{ lv_ypos }' MM WIDTH '20' MM HEIGHT '{ lv_height }' MM FRAME 01 TW|.
      CALL FUNCTION 'CONTROL_FORM'
        EXPORTING
          command = lv_cmd
        EXCEPTIONS
          OTHERS  = 1.

      lv_cmd = |BOX XPOS '72.5' MM YPOS '{ lv_ypos }' MM WIDTH '26' MM HEIGHT '{ lv_height }' MM FRAME 01 TW|.
      CALL FUNCTION 'CONTROL_FORM'
        EXPORTING
          command = lv_cmd
        EXCEPTIONS
          OTHERS  = 1.

      lv_cmd = |BOX XPOS '98.5' MM YPOS '{ lv_ypos }' MM WIDTH '25.5' MM HEIGHT '{ lv_height }' MM FRAME 01 TW|.
      CALL FUNCTION 'CONTROL_FORM'
        EXPORTING
          command = lv_cmd
        EXCEPTIONS
          OTHERS  = 1.

      lv_cmd = |BOX XPOS '124' MM YPOS '{ lv_ypos }' MM WIDTH '30.2' MM HEIGHT '{ lv_height }' MM FRAME 01 TW|.
      CALL FUNCTION 'CONTROL_FORM'
        EXPORTING
          command = lv_cmd
        EXCEPTIONS
          OTHERS  = 1.

      lv_cmd = |BOX XPOS '154.2' MM YPOS '{ lv_ypos }' MM WIDTH '20' MM HEIGHT '{ lv_height }' MM FRAME 01 TW|.
      CALL FUNCTION 'CONTROL_FORM'
        EXPORTING
          command = lv_cmd
        EXCEPTIONS
          OTHERS  = 1.

      DO lv_max_rows TIMES.

        READ TABLE gt_output INTO gs_output INDEX lv_display_line.

        IF gs_output-ebelp IS NOT INITIAL.

          READ TABLE gt_ekpo INTO gs_ekpo INDEX lv_display_line.
          WRITE gs_ekpo-menge UNIT gs_ekpo-meins TO gs_output-menge.

        ENDIF.

        CALL FUNCTION 'WRITE_FORM'
          EXPORTING
            element  = 'TABLE_VALUES'
            function = 'SET'
            type     = 'BODY'
            window   = 'MAIN'
          EXCEPTIONS
            OTHERS   = 10.

        lv_display_line += 1.

      ENDDO.

      lv_ypos += lv_height.

    ENDIF.

  ENDLOOP.

  LOOP AT gt_output INTO gs_output.

    gv_total = gv_total + gs_output-netpr_menge.

  ENDLOOP.

  lv_height = '5'.

  IF lv_ypos + lv_height <= lv_win_height.
    lv_cmd = |BOX XPOS '0' MM YPOS '{ lv_ypos }' MM WIDTH '124' MM HEIGHT '5' MM FRAME 01 TW|.
    CALL FUNCTION 'CONTROL_FORM'
      EXPORTING
        command = lv_cmd
      EXCEPTIONS
        OTHERS  = 1.

    lv_cmd = |BOX XPOS '124' MM YPOS '{ lv_ypos }' MM WIDTH '50.2' MM HEIGHT '5' MM FRAME 01 TW|.
    CALL FUNCTION 'CONTROL_FORM'
      EXPORTING
        command = lv_cmd
      EXCEPTIONS
        OTHERS  = 1.
  ENDIF.

  CALL FUNCTION 'WRITE_FORM'
    EXPORTING
      element                  = 'TABLE_TOTAL'
      function                 = 'APPEND'
      window                   = 'MAIN'
    EXCEPTIONS
      element                  = 1
      function                 = 2
      type                     = 3
      unopened                 = 4
      unstarted                = 5
      window                   = 6
      bad_pageformat_for_print = 7
      spool_error              = 8
      codepage                 = 9
      OTHERS                   = 10.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  DATA: lt_read_text TYPE TABLE OF tline,
        lv_name      TYPE thead-tdname.

  lv_name =  p_ebeln.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = 'F01'
      language                = sy-langu
      name                    = lv_name
      object                  = 'EKKO'
    TABLES
      lines                   = lt_read_text
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.

  IF sy-subrc <> 0.

* Implement suitable error handling here

  ENDIF.

  LOOP AT lt_read_text INTO gs_lines.

    CALL FUNCTION 'WRITE_FORM'
      EXPORTING
        element                  = 'READ_TEXT'
        window                   = 'MAIN'
      EXCEPTIONS
        element                  = 1
        function                 = 2
        type                     = 3
        unopened                 = 4
        unstarted                = 5
        window                   = 6
        bad_pageformat_for_print = 7
        spool_error              = 8
        codepage                 = 9
        OTHERS                   = 10.

    IF sy-subrc <> 0.

*    RETURN.

    ENDIF.

  ENDLOOP.

ENDFORM.
