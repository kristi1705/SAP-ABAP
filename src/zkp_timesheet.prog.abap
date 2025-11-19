*&---------------------------------------------------------------------*
*& Report ZKP_TIMESHEET
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zkp_timesheet.

TYPE-POOLS vrm.

TYPES: BEGIN OF ty_scr_110,
         ok_code TYPE sy-ucomm,
       END OF ty_scr_110.

DATA: gs_scr_110 TYPE ty_scr_110.

CLASS lcl_display DEFINITION.

  PUBLIC SECTION.

    TYPES: BEGIN OF ty_cl_employee,
             id      TYPE i,
             name    TYPE string,
             surname TYPE string,
           END OF ty_cl_employee,

           tt_cl_employee TYPE STANDARD TABLE OF ty_cl_employee.

    TYPES : BEGIN OF ty_cl_timesheet,
              employeeid  TYPE i,
              project     TYPE string,
              overtime(1) TYPE c,
              date        TYPE d,
              hours(3)    TYPE p DECIMALS 2,
            END OF ty_cl_timesheet,

            tt_cl_timesheet TYPE STANDARD TABLE OF ty_cl_timesheet.

    TYPES: BEGIN OF ty_output,
             select_lines TYPE abap_bool,
             name         TYPE string,
             project      TYPE string,
             hours(3)     TYPE p DECIMALS 2,
             days(3)      TYPE p DECIMALS 2,
             overtime(1)  TYPE c,
             col_color    TYPE slis_t_specialcol_alv,
             salv_color   TYPE lvc_t_scol,
             d_01(3)      TYPE p DECIMALS 2,
             d_02(3)      TYPE p DECIMALS 2,
             d_03(3)      TYPE p DECIMALS 2,
             d_04(3)      TYPE p DECIMALS 2,
             d_05(3)      TYPE p DECIMALS 2,
             d_06(3)      TYPE p DECIMALS 2,
             d_07(3)      TYPE p DECIMALS 2,
             d_08(3)      TYPE p DECIMALS 2,
             d_09(3)      TYPE p DECIMALS 2,
             d_10(3)      TYPE p DECIMALS 2,
             d_11(3)      TYPE p DECIMALS 2,
             d_12(3)      TYPE p DECIMALS 2,
             d_13(3)      TYPE p DECIMALS 2,
             d_14(3)      TYPE p DECIMALS 2,
             d_15(3)      TYPE p DECIMALS 2,
             d_16(3)      TYPE p DECIMALS 2,
             d_17(3)      TYPE p DECIMALS 2,
             d_18(3)      TYPE p DECIMALS 2,
             d_19(3)      TYPE p DECIMALS 2,
             d_20(3)      TYPE p DECIMALS 2,
             d_21(3)      TYPE p DECIMALS 2,
             d_22(3)      TYPE p DECIMALS 2,
             d_23(3)      TYPE p DECIMALS 2,
             d_24(3)      TYPE p DECIMALS 2,
             d_25(3)      TYPE p DECIMALS 2,
             d_26(3)      TYPE p DECIMALS 2,
             d_27(3)      TYPE p DECIMALS 2,
             d_28(3)      TYPE p DECIMALS 2,
             d_29(3)      TYPE p DECIMALS 2,
             d_30(3)      TYPE p DECIMALS 2,
             d_31(3)      TYPE p DECIMALS 2,
           END OF ty_output,

           tt_alv_output TYPE STANDARD TABLE OF ty_output.

    DATA: mt_output       TYPE tt_alv_output,
          mt_timesheet    TYPE tt_cl_timesheet,
          mt_employee     TYPE tt_cl_employee,
          mo_grid         TYPE REF TO cl_gui_alv_grid,
          mo_salv         TYPE REF TO cl_salv_table,
          mv_hide_weekend TYPE abap_bool.

    METHODS: execute IMPORTING iv_curr_date TYPE c
                               iv_hide      TYPE c
                               iv_choice    TYPE i.

    METHODS: convert_data.

    METHODS: reuse_alv IMPORTING iv_date      TYPE c,

      build_alv_fcat IMPORTING iv_date TYPE c
                     CHANGING  ct_fcat TYPE slis_t_fieldcat_alv,

      build_alv_layout CHANGING  cs_layout TYPE slis_layout_alv,

      sum_msg_reuse.

    METHODS: create_grid IMPORTING iv_date      TYPE c,

      build_grid_layout IMPORTING iv_date   TYPE c
                        CHANGING  ct_fcat   TYPE lvc_t_fcat
                                  cs_layout TYPE lvc_s_layo,

      add_grid_buttons FOR EVENT toolbar OF cl_gui_alv_grid IMPORTING e_object e_interactive,

      handle_grid_ucomm FOR EVENT user_command OF cl_gui_alv_grid IMPORTING e_ucomm,

      weekend_status_grid,

      sum_msg_grid.

    METHODS: create_salv IMPORTING iv_date TYPE c,

      set_columns IMPORTING iv_curr_date TYPE c,

      set_buttons,

      handle_salv_ucomm FOR EVENT added_function OF cl_salv_events_table IMPORTING e_salv_function,

      weekend_status_salv,

      sum_msg_salv.

ENDCLASS.

CLASS lcl_display IMPLEMENTATION.

  METHOD execute.

    convert_data( ).

    mv_hide_weekend = iv_hide.

    CASE iv_choice.

      WHEN 1.

        create_salv( EXPORTING iv_date = iv_curr_date ).

      WHEN 2.

        create_grid( EXPORTING iv_date = iv_curr_date ).

      WHEN 3.

        reuse_alv( EXPORTING iv_date = iv_curr_date ).

    ENDCASE.

  ENDMETHOD.

  METHOD convert_data.

    mt_employee = VALUE #( ( id = 1234 name = 'Filan'  surname = 'Fisteku' )
                         ( id = 32   name = 'Filane' surname = 'Fisteke' )
                         ( id = 54   name = 'Mondi'  surname = 'Nafies' )
                         ( id = 632   name = 'Limi'   surname = 'Feruzes' ) ).

    mt_timesheet = VALUE #( ( employeeid = 1234 project = 'Arts' date = '20220102' hours = '5.25' overtime = abap_true  )
                            ( employeeid = 1234 project = 'Arts' date = '20220102' hours = 8 )
                            ( employeeid = 1234 project = 'Arts' date = '20220115' hours = 8 )
                            ( employeeid = 1234 project = 'Arts' date = '20220103' hours = 8 )
                            ( employeeid = 1234 project = 'Arts' date = '20220101' hours = 5 )
                            ( employeeid = 32   project = 'Arts' date = '20220101' hours = 5 )
                            ( employeeid = 54   project = 'Arts' date = '20220101' hours = 5 )
                            ( employeeid = 632  project = 'Arts' date = '20220101' hours = 5 ) ).

    FIELD-SYMBOLS: <lv_hours> TYPE p.

    IF mt_output IS INITIAL.

      LOOP AT mt_timesheet ASSIGNING FIELD-SYMBOL(<ls_timesheet>)
      GROUP BY ( employeeid = <ls_timesheet>-employeeid project = <ls_timesheet>-project overtime = <ls_timesheet>-overtime )
      ASSIGNING FIELD-SYMBOL(<lt_timesheet_group>).

        READ TABLE mt_employee ASSIGNING FIELD-SYMBOL(<ls_employee>) WITH KEY id = <lt_timesheet_group>-employeeid.

        APPEND INITIAL LINE TO mt_output ASSIGNING FIELD-SYMBOL(<ls_output>).

        <ls_output>-name      = |{ <ls_employee>-name } { <ls_employee>-surname }|.
        <ls_output>-project   = <lt_timesheet_group>-project.
        <ls_output>-overtime  = <lt_timesheet_group>-overtime.

        CASE <lt_timesheet_group>-overtime.

          WHEN 'X'.

            APPEND INITIAL LINE TO <ls_output>-salv_color ASSIGNING FIELD-SYMBOL(<ls_salv_color>).
            <ls_salv_color>-color-col = col_negative.
            <ls_salv_color>-color-int = 1.

        ENDCASE.

        LOOP AT GROUP <lt_timesheet_group> ASSIGNING FIELD-SYMBOL(<ls_timesheet_group>).

          DATA(lv_day) = 'D_' && <ls_timesheet_group>-date+6(2).

          ASSIGN COMPONENT lv_day OF STRUCTURE <ls_output> TO <lv_hours>.

          <lv_hours> = <ls_timesheet_group>-hours.
          <ls_output>-hours += <lv_hours>.
          <ls_output>-days   = <ls_output>-hours / 8.

        ENDLOOP.

      ENDLOOP.

    ENDIF.

  ENDMETHOD.

  METHOD build_alv_layout.

    cs_layout-zebra = 'X'.
    cs_layout-colwidth_optimize = 'X'.
    cs_layout-box_fieldname = 'SELECT_LINES'.
    cs_layout-coltab_fieldname = 'COL_COLOR'.
    cs_layout-cell_merge = ' '.

  ENDMETHOD.

  METHOD build_alv_fcat.

    CONSTANTS: c_tabname TYPE string VALUE 'IT_OUTPUT'.

    DATA: lv_date          TYPE d,
          lv_days_in_month TYPE t009b-butag,
          lv_weekday       TYPE sc_day_txt,
          lv_day_name      TYPE string,
          lv_day_num(2)    TYPE n,
          ls_col_color     TYPE slis_specialcol_alv,
          ls_output        TYPE ty_output,
          lv_col_pos       TYPE i.

    FIELD-SYMBOLS: <lv_weekend> TYPE any.

    CLEAR ct_fcat.

    lv_date = iv_date.

    ct_fcat = VALUE #( ( fieldname = 'SELECTED_LINES' tabname = c_tabname no_out = 'X' col_pos = 1 )
                       ( fieldname = 'NAME' tabname = c_tabname seltext_m = 'Name' key = 'X' col_pos = 2 )
                       ( fieldname = 'PROJECT' tabname = c_tabname seltext_m = 'Project' key = 'X' col_pos = 3 )
                       ( fieldname = 'HOURS' tabname = c_tabname seltext_m = 'Hours' key = 'X' col_pos = 4 )
                       ( fieldname = 'DAYS' tabname = c_tabname seltext_m = 'Days' key = 'X' col_pos = 5 ) ).

    lv_col_pos = 5.

    CALL FUNCTION 'NUMBER_OF_DAYS_PER_MONTH_GET'
      EXPORTING
        par_month = lv_date+4(2)
        par_year  = lv_date(4)
      IMPORTING
        par_days  = lv_days_in_month.

    DO lv_days_in_month TIMES.

      CALL FUNCTION 'DATE_COMPUTE_DAY_ENHANCED'
        EXPORTING
          date    = lv_date
        IMPORTING
          weekday = lv_weekday.

      lv_day_num += 1.
      lv_day_name = |{ lv_date+6(2) } { lv_weekday(3) }|.
      DATA(lv_fieldname) = 'D_' && lv_day_num.

      LOOP AT mt_output INTO ls_output.

        ASSIGN COMPONENT lv_fieldname OF STRUCTURE ls_output TO <lv_weekend>.

        CASE ls_output-overtime.

          WHEN 'X'.
            ls_col_color-fieldname = lv_fieldname.
            ls_col_color-color-col = '6'.
            ls_col_color-color-int = '1'.
            APPEND ls_col_color TO ls_output-col_color.
            CLEAR ls_col_color.
            MODIFY mt_output FROM ls_output.

        ENDCASE.

        IF ( lv_day_name CS 'SUN' OR lv_day_name CS 'SAT' ) AND <lv_weekend> IS NOT INITIAL.

          ls_col_color-fieldname = lv_fieldname.
          ls_col_color-color-col = '6'.
          ls_col_color-color-int = '1'.
          APPEND ls_col_color TO ls_output-col_color.
          CLEAR ls_col_color.
          MODIFY mt_output FROM ls_output.

        ENDIF.

      ENDLOOP.

      lv_col_pos += 1.

      IF ( lv_weekday = 'SATURDAY' OR lv_weekday = 'SUNDAY' ) AND mv_hide_weekend IS NOT INITIAL.

        APPEND
     VALUE #( fieldname = lv_fieldname
                                tabname   = c_tabname
                                seltext_m = lv_day_name
                                no_out    = 'X'
                                no_zero   = 'X'
                                col_pos   = lv_col_pos ) TO ct_fcat.

      ELSE.

        APPEND VALUE #( fieldname = lv_fieldname
                                tabname   = c_tabname
                                seltext_m = lv_day_name
                                col_pos   = lv_col_pos
                                no_zero   = 'X' ) TO ct_fcat.
      ENDIF.

      lv_date += 1.

    ENDDO.

  ENDMETHOD.

  METHOD sum_msg_reuse.

    DATA: lv_sum_days  TYPE p DECIMALS 2,
          lv_sum_hours TYPE p DECIMALS 2.

    LOOP AT mt_output ASSIGNING FIELD-SYMBOL(<ls_output>) WHERE select_lines = 'X'.

      lv_sum_days  += <ls_output>-days.
      lv_sum_hours += <ls_output>-hours.

    ENDLOOP.

    IF lv_sum_days IS NOT INITIAL OR lv_sum_hours IS NOT INITIAL.

      MESSAGE 'Sum of days is: ' && lv_sum_days && '. ' && 'Sum of hours is: ' && lv_sum_hours && '.' TYPE 'I'.

    ENDIF.

  ENDMETHOD.

  METHOD reuse_alv.

    DATA: lt_alv_output TYPE tt_alv_output,
          lt_fcat       TYPE slis_t_fieldcat_alv,
          ls_layout     TYPE slis_layout_alv.

    build_alv_fcat( EXPORTING iv_date = iv_date CHANGING ct_fcat = lt_fcat ).

    build_alv_layout( CHANGING cs_layout = ls_layout ).

    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        i_callback_program       = sy-repid
        i_callback_pf_status_set = 'PF_STATUS'
        i_callback_user_command  = 'REUSE_UCOMM'
        is_layout                = ls_layout
        it_fieldcat              = lt_fcat
      TABLES
        t_outtab                 = mt_output
      EXCEPTIONS
        program_error            = 1
        OTHERS                   = 2.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

  ENDMETHOD.

  METHOD create_grid.

    DATA: lt_fcat      TYPE lvc_t_fcat,
          ls_layout    TYPE lvc_s_layo,
          lo_container TYPE REF TO cl_gui_custom_container.

    CREATE OBJECT lo_container EXPORTING container_name = 'GS_SCR_110_CONTAINER'.
    CREATE OBJECT mo_grid EXPORTING i_parent = lo_container.

    build_grid_layout( EXPORTING iv_date = iv_date
                       CHANGING ct_fcat = lt_fcat
                                cs_layout = ls_layout ).

    MOVE 'COL_COLOR' TO ls_layout-ctab_fname.
    CLEAR ls_layout-box_fname.

    SET HANDLER add_grid_buttons FOR mo_grid.
    SET HANDLER handle_grid_ucomm FOR mo_grid.

    mo_grid->set_table_for_first_display(
      EXPORTING
        is_layout                     = ls_layout
      CHANGING
        it_outtab                     = mt_output
        it_fieldcatalog               = lt_fcat ).

    CALL SCREEN 110.

  ENDMETHOD.

  METHOD build_grid_layout.

    DATA: lt_alv_fcat TYPE slis_t_fieldcat_alv,
          ls_layout   TYPE slis_layout_alv.

    build_alv_layout( CHANGING cs_layout = ls_layout ).

    build_alv_fcat( EXPORTING iv_date = iv_date CHANGING  ct_fcat = lt_alv_fcat ).

    CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
      EXPORTING
        it_fieldcat_alv = lt_alv_fcat
        is_layout_alv   = ls_layout
      IMPORTING
        et_fieldcat_lvc = ct_fcat
        es_layout_lvc   = cs_layout
      TABLES
        it_data         = mt_output
      EXCEPTIONS
        it_data_missing = 1
        OTHERS          = 2.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

  ENDMETHOD.

  METHOD add_grid_buttons.

    DATA: ls_show TYPE stb_button,
          ls_sum  TYPE stb_button.

    CLEAR: ls_show, ls_sum.

    MOVE 'FC_SHOW' TO ls_show-function.
    MOVE icon_display TO ls_show-icon.
    MOVE 'Show' TO ls_show-text.
    MOVE 'Show / Hide Weekends' TO ls_show-quickinfo.
    APPEND ls_show TO e_object->mt_toolbar.

    MOVE 'FC_SUM' TO ls_sum-function.
    MOVE icon_sum TO ls_sum-icon.
    MOVE 'Sum Data' TO ls_sum-text.
    MOVE 'Sum of selected days and hours.' TO ls_sum-quickinfo.
    APPEND ls_sum TO e_object->mt_toolbar.

  ENDMETHOD.

  METHOD handle_grid_ucomm.

    CASE e_ucomm.

      WHEN 'FC_SHOW'.

        weekend_status_grid( ).

      WHEN 'FC_SUM'.

        sum_msg_grid( ).

    ENDCASE.

  ENDMETHOD.

  METHOD weekend_status_grid.

    DATA: lt_fcat   TYPE lvc_t_fcat,
          ls_fcat   TYPE lvc_s_fcat,
          ls_layout TYPE lvc_s_layo.

    mo_grid->get_frontend_fieldcatalog( IMPORTING et_fieldcatalog = lt_fcat ).
    mo_grid->get_frontend_layout( IMPORTING es_layout = ls_layout ).

    CASE mv_hide_weekend.

      WHEN 'X'.

        mv_hide_weekend = ' '.

        LOOP AT lt_fcat INTO ls_fcat.

          ls_fcat-col_pos = sy-tabix.

          IF ls_fcat-no_out = 'X' AND ls_fcat-fieldname <> 'SELECTED_LINES'.

            ls_fcat-no_out = ' '.

          ENDIF.

          MODIFY lt_fcat FROM ls_fcat TRANSPORTING no_out col_pos.

        ENDLOOP.

      WHEN ' '.

        mv_hide_weekend = 'X'.

        LOOP AT lt_fcat INTO ls_fcat.

          ls_fcat-col_pos = sy-tabix.

          IF ls_fcat-seltext CS 'SUN' OR ls_fcat-seltext CS 'SAT'.

            ls_fcat-no_out = 'X'.

          ENDIF.

          MODIFY lt_fcat FROM ls_fcat TRANSPORTING no_out col_pos.

        ENDLOOP.

    ENDCASE.

    ls_layout-cwidth_opt = 'X'.

    mo_grid->set_frontend_fieldcatalog( EXPORTING it_fieldcatalog = lt_fcat ).
    mo_grid->set_frontend_layout( EXPORTING is_layout = ls_layout ).

  ENDMETHOD.

  METHOD sum_msg_grid.

    DATA: lv_sum_days  TYPE p DECIMALS 2,
          lv_sum_hours TYPE p DECIMALS 2,
          lt_row_num   TYPE lvc_t_row,
          lv_index     TYPE i.

    mo_grid->get_selected_rows( IMPORTING et_index_rows = lt_row_num ).

    LOOP AT lt_row_num ASSIGNING FIELD-SYMBOL(<ls_num>).

      lv_index = <ls_num>-index.

      READ TABLE mt_output ASSIGNING FIELD-SYMBOL(<ls_output>) INDEX lv_index.

      lv_sum_days  += <ls_output>-days.
      lv_sum_hours += <ls_output>-hours.

    ENDLOOP.

    IF lv_sum_days IS NOT INITIAL OR lv_sum_hours IS NOT INITIAL.

      MESSAGE 'Sum of days is: ' && lv_sum_days && '. ' && 'Sum of hours is: ' && lv_sum_hours && '.' TYPE 'I'.

    ENDIF.

  ENDMETHOD.

  METHOD create_salv.

    DATA: lo_container TYPE REF TO cl_gui_custom_container.

    CREATE OBJECT lo_container EXPORTING container_name = 'GS_SCR_110_CONTAINER'.

    TRY.

        CALL METHOD cl_salv_table=>factory
          EXPORTING
            r_container    = lo_container
            container_name = 'GS_SCR_110_CONTAINER'
          IMPORTING
            r_salv_table   = mo_salv
          CHANGING
            t_table        = mt_output.

        set_columns( EXPORTING iv_curr_date = iv_date ).
        set_buttons( ).

        DATA(lo_events) = mo_salv->get_event( ).

        SET HANDLER handle_salv_ucomm FOR lo_events.

        CALL METHOD mo_salv->if_salv_gui_om_table_action~display.

      CATCH cx_root INTO DATA(e_txt).
        WRITE: / e_txt->get_text( ).
    ENDTRY.

    CALL SCREEN 110.

  ENDMETHOD.

  METHOD set_columns.

    DATA: lv_date          TYPE d,
          lv_days_in_month TYPE t009b-butag,
          lv_weekday       TYPE sc_day_txt,
          lv_day_name      TYPE scrtext_m,
          lv_day_num(2)    TYPE n,
          ls_salv_color    TYPE lvc_s_scol,
          ls_output        TYPE ty_output,
          lv_fieldname     TYPE lvc_fname,
          lv_col_pos       TYPE i.

    FIELD-SYMBOLS: <lv_weekend> TYPE any.

    TRY.

        DATA(lo_columns) = mo_salv->get_columns( ).

        lo_columns->set_optimize( abap_true ).

        lv_date = iv_curr_date.

        DATA(lo_selection) = mo_salv->get_selections( ).

        lo_selection->set_selection_mode( if_salv_c_selection_mode=>row_column ).

        lo_columns->get_column( 'SELECT_LINES' )->set_technical( abap_true ).
        lo_columns->get_column( 'OVERTIME' )->set_technical( abap_true ).

        lo_columns->set_column_position(  columnname = 'NAME' position   = 1 ).
        lo_columns->set_column_position(  columnname = 'PROJECT' position   = 2 ).
        lo_columns->set_column_position(  columnname = 'HOURS' position   = 3 ).
        lo_columns->set_column_position(  columnname = 'DAYS' position   = 4 ).

        lv_col_pos = 5.

        DATA(lo_column) = CAST cl_salv_column_table( lo_columns->get_column( 'NAME' ) ).

        lo_column->set_medium_text( 'Name' ).
        lo_column->set_key( ).

        lo_column = CAST cl_salv_column_table( lo_columns->get_column( 'PROJECT' ) ).
        lo_column->set_medium_text( 'Project' ).
        lo_column->set_key( ).

        lo_column = CAST cl_salv_column_table( lo_columns->get_column( 'HOURS' ) ).
        lo_column->set_medium_text( 'Hours' ).
        lo_column->set_key( ).

        lo_column = CAST cl_salv_column_table( lo_columns->get_column( 'DAYS' ) ).
        lo_column->set_medium_text( 'Days' ).
        lo_column->set_key( ).

        CALL FUNCTION 'NUMBER_OF_DAYS_PER_MONTH_GET'
          EXPORTING
            par_month = lv_date+4(2)
            par_year  = lv_date(4)
          IMPORTING
            par_days  = lv_days_in_month.

        DO lv_days_in_month TIMES.

          CALL FUNCTION 'DATE_COMPUTE_DAY_ENHANCED'
            EXPORTING
              date    = lv_date
            IMPORTING
              weekday = lv_weekday.

          lv_day_num += 1.
          lv_day_name = |{ lv_date+6(2) } { lv_weekday(3) }|.
          lv_fieldname = 'D_' && lv_day_num.

          LOOP AT mt_output INTO ls_output.

            ASSIGN COMPONENT lv_fieldname OF STRUCTURE ls_output TO <lv_weekend>.

            IF ( lv_day_name CS 'SUN' OR lv_day_name CS 'SAT' ) AND <lv_weekend> IS NOT INITIAL.

              ls_salv_color-fname = lv_fieldname.
              ls_salv_color-color-col = col_negative.
              ls_salv_color-color-int = 1.
              APPEND ls_salv_color TO ls_output-salv_color.
              MODIFY mt_output FROM ls_output.
              CLEAR ls_salv_color.

            ELSEIF <lv_weekend> IS INITIAL.

              lo_column = CAST cl_salv_column_table( lo_columns->get_column( lv_fieldname ) ).
              lo_column->set_zero( abap_false ).

            ENDIF.

          ENDLOOP.

          IF ( lv_weekday = 'SATURDAY' OR lv_weekday = 'SUNDAY' ) AND mv_hide_weekend IS NOT INITIAL.

            lo_columns->get_column( lv_fieldname )->set_medium_text( lv_day_name ).
            lo_columns->get_column( lv_fieldname )->set_visible( abap_false ).
            lo_columns->set_column_position(  columnname = lv_fieldname position   = lv_col_pos ).

          ELSE.

            lo_columns->get_column( lv_fieldname )->set_medium_text( lv_day_name ).
            lo_columns->set_column_position(  columnname = lv_fieldname position   = lv_col_pos ).

          ENDIF.

          lv_date    += 1.
          lv_col_pos += 1.

        ENDDO.

        lo_columns->set_color_column( 'SALV_COLOR' ).

      CATCH cx_root INTO DATA(e_txt).
        WRITE: / e_txt->get_text( ).
    ENDTRY.

  ENDMETHOD.

  METHOD set_buttons.

    DATA(lo_functions) = mo_salv->get_functions( ).

    lo_functions->set_all( abap_true ).

    INCLUDE <icon>.

    TRY.

        lo_functions->add_function(
          name     = 'FC_SHOW'
          icon     = CONV string( icon_display )
          text     = `Show`
          tooltip  = `Show / Hide Weekends`
          position = if_salv_c_function_position=>right_of_salv_functions ).

      CATCH cx_salv_existing cx_salv_wrong_call.

    ENDTRY.

    TRY.

        lo_functions->add_function(
          name     = 'FC_SUM'
          icon     = CONV string( icon_sum )
          text     = `Sum Data`
          tooltip  = `Sum of days and hours of selected rows`
          position = if_salv_c_function_position=>right_of_salv_functions ).

      CATCH cx_salv_existing cx_salv_wrong_call.

    ENDTRY.

  ENDMETHOD.

  METHOD handle_salv_ucomm.

    CASE e_salv_function.

      WHEN 'FC_SHOW'.

        weekend_status_salv( ).

      WHEN 'FC_SUM'.

        sum_msg_salv( ).

    ENDCASE.

  ENDMETHOD.

  METHOD weekend_status_salv.

    DATA: lv_index   TYPE i.

    FIELD-SYMBOLS <lS_column> TYPE salv_s_column_ref.
    FIELD-SYMBOLS <lt_columns_ref> TYPE salv_t_column_ref.
    CASE mv_hide_weekend.

      WHEN 'X'.

        mv_hide_weekend = ' '.
      WHEN ' '.

        mv_hide_weekend = 'X'.
    ENDCASE.

    DATA(lt_cols) = mo_salv->get_columns( )->get( ).

    LOOP AT lt_cols ASSIGNING <ls_column>.

      DATA(lv_tabix) = sy-tabix.

      IF <lS_column>-columnname(2) = 'D_'.

        DATA(lv_day) = CONV numc2( <lS_column>-columnname+2(2) ).
        lv_tabix = lv_day + 4.

      ENDIF.

      mo_salv->get_columns( )->set_column_position( columnname = <lS_column>-columnname
      position = lv_tabix ).

      CASE mv_hide_weekend.

        WHEN abap_false.

          IF <ls_column>-r_column->get_medium_text( ) CS 'SUN' OR <ls_column>-r_column->get_medium_text( ) CS 'SAT'.

            <ls_column>-r_column->set_visible( abap_true ).

          ENDIF.

        WHEN abap_true.

          IF <ls_column>-r_column->get_medium_text( ) CS 'SUN' OR <ls_column>-r_column->get_medium_text( ) CS 'SAT'.

            <ls_column>-r_column->set_visible( abap_false ).

          ENDIF.

      ENDCASE.

    ENDLOOP.

    mo_salv->get_columns( )->set_optimize( ).
    mo_salv->refresh( s_stable = VALUE lvc_s_stbl( col = 'X' ) ).

  ENDMETHOD.

  METHOD sum_msg_salv.

    DATA: lv_sum_hours TYPE p DECIMALS 2,
          lv_sum_days  TYPE p DECIMALS 2.

    DATA(lt_cols) = mo_salv->get_selections( )->get_selected_rows( ).

    LOOP AT lt_cols ASSIGNING FIELD-SYMBOL(<ls_cols>).

      DATA(lv_index) = <ls_cols>.

      READ TABLE mt_output ASSIGNING FIELD-SYMBOL(<ls_output>) INDEX lv_index.

      lv_sum_hours += <ls_output>-hours.
      lv_sum_days  += <ls_output>-days.

    ENDLOOP.

    IF lv_sum_days IS NOT INITIAL OR lv_sum_hours IS NOT INITIAL.

      MESSAGE 'Sum of days is: ' && lv_sum_days && '. ' && 'Sum of hours is: ' && lv_sum_hours && '.' TYPE 'I'.

    ENDIF.

  ENDMETHOD.

ENDCLASS.

PARAMETERS: p_year(4)   TYPE p DECIMALS 0 OBLIGATORY,
            p_month(10) AS LISTBOX VISIBLE LENGTH 10 OBLIGATORY,
            p_hide      AS CHECKBOX,
            p_salv      RADIOBUTTON GROUP rbg1 DEFAULT 'X',
            p_grid      RADIOBUTTON GROUP rbg1,
            p_reuse     RADIOBUTTON GROUP rbg1.

DATA: gt_values       TYPE vrm_values,
      gt_field_name   TYPE vrm_id,
      gv_date(8)      TYPE c,
      go_display      TYPE REF TO lcl_display,
      gv_weekend_hide TYPE abap_bool,
      gv_choice       TYPE i.

AT SELECTION-SCREEN OUTPUT.

  gt_field_name = 'P_MONTH'.

  Gt_values = VALUE #( ( key = '01' text = 'January' )
                       ( key = '02' text = 'February' )
                       ( key = '03' text = 'March' )
                       ( key = '04' text = 'April' )
                       ( key = '05' text = 'May' )
                       ( key = '06' text = 'June' )
                       ( key = '07' text = 'July' )
                       ( key = '08' text = 'August' )
                       ( key = '09' text = 'September' )
                       ( key = '10' text = 'October' )
                       ( key = '11' text = 'November' )
                       ( key = '12' text = 'December' ) ).

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id     = gt_field_name
      values = gt_values[]
    EXCEPTIONS
      OTHERS = 1.

START-OF-SELECTION.

  CREATE OBJECT go_display.

  gv_date = |{ p_year }{ p_month }01|.

  gv_weekend_hide = p_hide.

  IF p_salv = 'X'.

    gv_choice = 1.

  ELSEIF p_grid = 'X'.

    gv_choice = 2.

  ELSEIF p_reuse = 'X'.

    gv_choice = 3.

  ENDIF.

  go_display->execute( EXPORTING  iv_curr_date = gv_date
                                    iv_hide = gv_weekend_hide
                                    iv_choice = gv_choice ).

FORM reuse_ucomm USING uv_ucomm    TYPE sy-ucomm
                    uv_selfield TYPE slis_selfield.

  DATA: lt_fcat   TYPE slis_t_fieldcat_alv,
        ls_fcat   TYPE slis_fieldcat_alv,
        ls_layout TYPE slis_layout_alv.

  CALL FUNCTION 'REUSE_ALV_GRID_LAYOUT_INFO_GET'
    IMPORTING
      es_layout     = ls_layout
      et_fieldcat   = lt_fcat
    EXCEPTIONS
      no_infos      = 1
      program_error = 2
      OTHERS        = 3.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  LOOP AT lt_fcat INTO ls_fcat.

    ls_fcat-col_pos = sy-tabix.
    MODIFY lt_fcat FROM ls_fcat TRANSPORTING col_pos.

  ENDLOOP.


  uv_selfield-refresh = 'X'.

  CASE uv_ucomm.

    WHEN '&FC_SHOW'.

      CASE gv_weekend_hide.

        WHEN 'X'.

          gv_weekend_hide = ' '.

          LOOP AT lt_fcat INTO ls_fcat.

            ls_fcat-col_pos = sy-tabix.

            IF ls_fcat-no_out = 'X' AND ls_fcat-fieldname <> 'SELECTED_LINES'.

              ls_fcat-no_out = ' '.

            ENDIF.

            MODIFY lt_fcat FROM ls_fcat TRANSPORTING no_out col_pos.

          ENDLOOP.

        WHEN ' '.

          gv_weekend_hide = 'X'.

          LOOP AT lt_fcat INTO ls_fcat.

            ls_fcat-col_pos = sy-tabix.

            IF ls_fcat-seltext_m CS 'SUN' OR ls_fcat-seltext_m CS 'SAT'.

              ls_fcat-no_out = 'X'.

            ENDIF.

            MODIFY lt_fcat FROM ls_fcat TRANSPORTING no_out col_pos.

          ENDLOOP.

      ENDCASE.

      ls_layout-colwidth_optimize = 'X'.

      CALL FUNCTION 'REUSE_ALV_GRID_LAYOUT_INFO_SET'
        EXPORTING
          is_layout   = ls_layout
          it_fieldcat = lt_fcat.

    WHEN '&FC_SUM'.

      go_display->sum_msg_reuse( ).

  ENDCASE.
ENDFORM.

FORM pf_status USING ut_extab TYPE slis_t_extab.

  SET PF-STATUS 'PF_STATUS' EXCLUDING ut_extab.

ENDFORM.
*&---------------------------------------------------------------------*
*& Module STATUS_0110 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0110 OUTPUT.
  SET PF-STATUS 'PF_STATUS_0110'.
  SET TITLEBAR 'TB_0110'.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0110  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0110 INPUT.

  CASE gs_scr_110-ok_code.

    WHEN 'FC_BACK'.

      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.
