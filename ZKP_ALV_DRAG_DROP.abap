*&---------------------------------------------------------------------*
*& Report ZKP_TEST
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zkp_test.

TYPES: BEGIN OF ty_alv_fields,
         icon       TYPE icon_d,
         field_name TYPE fieldname,
         desc       TYPE text50,
         is_active  TYPE abap_bool,
       END OF ty_alv_fields,
       tt_alv_fields TYPE STANDARD TABLE OF ty_alv_fields.

CLASS lcl_dragdrop DEFINITION.

  PUBLIC SECTION.

    DATA: line  TYPE ty_alv_fields,
          index TYPE i.

ENDCLASS.

CLASS lcl_app DEFINITION.

  PUBLIC SECTION.

    METHODS:
      constructor,
      execute,
      pai_0100 IMPORTING iv_ucomm TYPE sy-ucomm.

  PRIVATE SECTION.

    TYPES: BEGIN OF ty_hierarchy,
             gjahr     TYPE acdoca-gjahr,
             monat     TYPE int4,
             kunnr     TYPE acdoca-kunnr,
             rhcur     TYPE acdoca-rhcur,
             rbukrs    TYPE acdoca-rbukrs,
             drcrk     TYPE acdoca-drcrk,
             net_sum   TYPE acdoca-hsl,
             tax_sum   TYPE acdoca-hsl,
             gross_sum TYPE acdoca-hsl,
             count     TYPE i,
           END OF ty_hierarchy,
           tt_hiearchy TYPE STANDARD TABLE OF ty_hierarchy.

    TYPES: BEGIN OF ty_node_keys,
             level        TYPE i,
             parent_value TYPE string,
             key          TYPE lvc_nkey,
           END OF ty_node_keys,
           tt_node_keys TYPE STANDARD TABLE OF ty_node_keys.

    DATA: mo_splitter         TYPE REF TO cl_gui_splitter_container,
          mo_container        TYPE REF TO cl_gui_custom_container,
          mo_tree             TYPE REF TO cl_gui_alv_tree,
          mo_grid             TYPE REF TO cl_gui_alv_grid,
          mt_nodes            TYPE tt_alv_fields,
          mt_node_keys        TYPE tt_node_keys,
          mt_tree_outtab      TYPE tt_hiearchy,
          mt_hierarchy        TYPE tt_hiearchy,
          mt_sort             TYPE abap_sortorder_tab,
          mv_delete_duplicate TYPE string.

    METHODS:
      fill_alv_table,
      build_alv,
      drag_row          FOR EVENT ondrag OF cl_gui_alv_grid         IMPORTING e_row e_column es_row_no e_dragdropobj,
      drop_row          FOR EVENT ondrop OF cl_gui_alv_grid         IMPORTING e_row e_column es_row_no e_dragdropobj,
      drop_row_complete FOR EVENT ondropcomplete OF cl_gui_alv_grid IMPORTING e_row e_column es_row_no e_dragdropobj,
      handle_hotspot_click FOR EVENT hotspot_click OF cl_gui_alv_grid IMPORTING es_row_no.


    METHODS:
      fill_tree_hierarchy,
      build_tree,
      update_tree,
      add_tree_node.

ENDCLASS.

DATA go_app TYPE REF TO lcl_app.

CLASS lcl_app IMPLEMENTATION.

  METHOD constructor.

    fill_alv_table( ).
    fill_tree_hierarchy( ).

  ENDMETHOD.

  METHOD execute.

    IF mo_container IS NOT BOUND.

      CREATE OBJECT mo_container
        EXPORTING
          container_name              = 'MAIN_CONT'
        EXCEPTIONS
          cntl_error                  = 1                " CNTL_ERROR
          cntl_system_error           = 2                " CNTL_SYSTEM_ERROR
          create_error                = 3                " CREATE_ERROR
          lifetime_error              = 4                " LIFETIME_ERROR
          lifetime_dynpro_dynpro_link = 5                " LIFETIME_DYNPRO_DYNPRO_LINK
          OTHERS                      = 6.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

      CREATE OBJECT mo_splitter
        EXPORTING
          parent            = mo_container       " Parent Container
          rows              = 1                  " Number of Rows to be displayed
          columns           = 2                  " Number of Columns to be Displayed
        EXCEPTIONS
          cntl_error        = 1                  " See Superclass
          cntl_system_error = 2                  " See Superclass
          OTHERS            = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

      mo_splitter->set_column_width(
        EXPORTING
          id                = 1                " Column ID
          width             = 10               " NPlWidth
        EXCEPTIONS
          cntl_error        = 1                " See CL_GUI_CONTROL
          cntl_system_error = 2                " See CL_GUI_CONTROL
          OTHERS            = 3
      ).
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

      DATA(lo_grid_cont) = mo_splitter->get_container(
        EXPORTING
          row    = 1                 " Row
          column = 1                 " Column
      ).

      CREATE OBJECT mo_grid
        EXPORTING
          i_parent          = lo_grid_cont     " Parent Container
        EXCEPTIONS
          error_cntl_create = 1                " Error when creating the control
          error_cntl_init   = 2                " Error While Initializing Control
          error_cntl_link   = 3                " Error While Linking Control
          error_dp_create   = 4                " Error While Creating DataProvider Control
          OTHERS            = 5.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

      DATA(lo_tree_cont) = mo_splitter->get_container(
        EXPORTING
          row    = 1                 " Row
          column = 2                 " Column
      ).

      CREATE OBJECT mo_tree
        EXPORTING
          parent                      = lo_tree_cont                             " Parent Container
          no_html_header              = abap_true                             " Parent Container
        EXCEPTIONS
          cntl_error                  = 1                                        " CNTL_ERROR
          cntl_system_error           = 2                                        " CNTL_SYSTEM_ERROR
          create_error                = 3                                        " CREATE_ERROR
          lifetime_error              = 4                                        " LIFETIME_ERROR
          illegal_node_selection_mode = 5                                        " ILLEGAL_NODE_SELECTION_MODE
          failed                      = 6                                        " Failed
          illegal_column_name         = 7                                        " ILLEGAL_COLUMN_NAME
          OTHERS                      = 8.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

    ENDIF.

    build_alv( ).
    build_tree( ).

  ENDMETHOD.

  METHOD drag_row.

    DATA lo_drag_drop TYPE REF TO lcl_dragdrop.

    READ TABLE mt_nodes ASSIGNING FIELD-SYMBOL(<ls_data>) INDEX e_row-index.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    lo_drag_drop = NEW #( ).

    lo_drag_drop->line    = <ls_data>.
    lo_drag_drop->index   = e_row-index.
    e_dragdropobj->object = lo_drag_drop.

  ENDMETHOD.

  METHOD drop_row.

    DATA: lo_drag_drop TYPE REF TO lcl_dragdrop.

    IF e_row-index IS INITIAL.
      e_row-index = 1.
    ENDIF.

    READ TABLE mt_nodes ASSIGNING FIELD-SYMBOL(<ls_data>) INDEX e_row-index.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    CATCH SYSTEM-EXCEPTIONS move_cast_error = 1.

      lo_drag_drop ?= e_dragdropobj->object.
      DATA(ls_data) = lo_drag_drop->line.

      INSERT ls_data INTO mt_nodes INDEX e_row-index.

      IF lo_drag_drop->index > e_row-index.
        lo_drag_drop->index   += 1.
        e_dragdropobj->object ?= lo_drag_drop.
      ENDIF.

    ENDCATCH.

  ENDMETHOD.

  METHOD handle_hotspot_click.

    READ TABLE mt_nodes ASSIGNING FIELD-SYMBOL(<ls_node>) INDEX es_row_no-row_id.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    IF <ls_node>-is_active IS INITIAL.
      <ls_node>-is_active = abap_true.
    ELSE.
      CLEAR <ls_node>-is_active.
    ENDIF.

    update_tree( ).

  ENDMETHOD.

  METHOD update_tree.

    DATA ls_stable    TYPE lvc_s_stbl.

    ls_stable-row = abap_true.
    ls_stable-col = abap_true.

    mo_grid->refresh_table_display(
      EXPORTING
        is_stable = ls_stable        " With Stable Rows/Columns
      EXCEPTIONS
        finished  = 1                " Display was Ended (by Export)
        OTHERS    = 2
    ).
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    fill_tree_hierarchy( ).
    add_tree_node( ).

  ENDMETHOD.

  METHOD drop_row_complete.

    DATA: lo_drag_drop TYPE REF TO lcl_dragdrop.

    CATCH SYSTEM-EXCEPTIONS move_cast_error = 1.

      lo_drag_drop ?= e_dragdropobj->object.

      IF e_dragdropobj->effect = cl_dragdrop=>move.

        DELETE mt_nodes INDEX lo_drag_drop->index.

      ENDIF.

    ENDCATCH.

    IF sy-subrc = 0.

      update_tree( ).

    ENDIF.

  ENDMETHOD.

  METHOD fill_tree_hierarchy.

    DATA: lv_select    TYPE string,
          lv_group_by  TYPE string,
          lv_fieldname TYPE string.

    CLEAR mt_hierarchy.

    LOOP AT mt_nodes ASSIGNING FIELD-SYMBOL(<ls_node>) WHERE is_active = abap_true.

      IF <ls_node>-field_name = 'MONAT'.
        lv_fieldname = 'extract_month( budat ) AS monat'.
      ELSE.
        lv_fieldname = <ls_node>-field_name.
      ENDIF.

      IF lv_select IS INITIAL.
        lv_select = lv_fieldname.
      ELSE.
        lv_select = |{ lv_select }, { lv_fieldname }|.
      ENDIF.

    ENDLOOP.

    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    lv_group_by = lv_select.
    REPLACE FIRST OCCURRENCE OF 'AS monat' IN lv_group_by WITH space.
    lv_select = |{ lv_select }, SUM( HSL ) AS NET_SUM, SUM( KSL ) AS TAX_SUM |.

    SELECT (lv_select)
      FROM acdoca
      WHERE kunnr <> ''
      AND rldnr = '0L'
      AND hsl <> 0
      GROUP BY (lv_group_by)
      ORDER BY (lv_group_by)
      INTO CORRESPONDING FIELDS OF TABLE @mt_hierarchy
      UP TO 100 ROWS.

    MODIFY mt_hierarchy FROM VALUE #( count = 1 ) TRANSPORTING count WHERE count = 0.

  ENDMETHOD.

  METHOD fill_alv_table.

    mt_nodes  = VALUE #(
    is_active = abap_true
           ( field_name = 'GJAHR'  desc = 'Year'           icon = icon_wd_numeric_value )
           ( field_name = 'MONAT'  desc = 'Month'          icon = icon_date             )
           ( field_name = 'RBUKRS' desc = 'Company Code'   icon = icon_company_code     )
           ( field_name = 'KUNNR'  desc = 'Customer'       icon = icon_customer         )
           ( field_name = 'RHCUR'  desc = 'Currency'       icon = icon_convert          )
           ( field_name = 'DRCRK'  desc = 'Debit / Credit' icon = icon_sum              )
   ).

  ENDMETHOD.

  METHOD build_tree.

    DATA(lt_fcat)   = VALUE lvc_t_fcat(
          ref_field = 'HSL'
          ref_table = 'ACDOCA'
          do_sum    = 'X'
        ( fieldname = 'NET_SUM' coltext = 'Net'      )
        ( fieldname = 'TAX_SUM' coltext = 'Tax'      )
        ( fieldname = 'COUNT'   coltext = 'Count'    )
   ).

    DATA(ls_hhdr) = VALUE treev_hhdr( heading = 'Edocument'(001) width = 40 ).

    mo_tree->set_table_for_first_display(
      EXPORTING
        is_hierarchy_header = ls_hhdr
      CHANGING
        it_fieldcatalog     = lt_fcat
        it_outtab           = mt_tree_outtab
    ).

    add_tree_node( ).

    CALL SCREEN 100.

  ENDMETHOD.

  METHOD add_tree_node.

    TYPES: BEGIN OF ty_open_nodes,
             value          TYPE string,
             node_id        TYPE lvc_nkey,
             parent_node_id TYPE lvc_nkey,
           END OF ty_open_nodes,
           tt_open_nodes TYPE STANDARD TABLE OF ty_open_nodes.

    DATA: lt_open_nodes TYPE tt_open_nodes,
          lv_node_text  TYPE lvc_value,
          lv_node_desc  TYPE lvc_value.

    mo_tree->delete_all_nodes( ).

    IF mt_hierarchy IS NOT INITIAL.

      SELECT bukrs,
             butxt
        FROM t001
        FOR ALL ENTRIES IN @mt_hierarchy
        WHERE bukrs = @mt_hierarchy-rbukrs
        ORDER BY PRIMARY KEY
        INTO TABLE @DATA(lt_bukrs_desc).

      SELECT kunnr,
             name1
        FROM kna1
        FOR ALL ENTRIES IN @mt_hierarchy
        WHERE kunnr = @mt_hierarchy-kunnr
        ORDER BY PRIMARY KEY
        INTO TABLE @DATA(lt_kunnr_desc).

      SELECT mnr,
             ltx
        FROM t247
        WHERE spras = 'E'
        ORDER BY PRIMARY KEY
        INTO TABLE @DATA(lt_monat_desc).

      DATA(lv_tot_nodes) = REDUCE i( INIT   tot_nodes TYPE i
                                     FOR    <ls_nd>   IN   mt_nodes
                                     WHERE ( is_active = abap_true )
                                     NEXT  tot_nodes = tot_nodes + 1 ).

    ENDIF.

    LOOP AT mt_hierarchy ASSIGNING FIELD-SYMBOL(<ls_hierarchy>).

      DATA(lv_tabix) = 0.

      LOOP AT mt_nodes ASSIGNING FIELD-SYMBOL(<ls_node>) WHERE is_active = abap_true.

        lv_tabix += 1.

        ASSIGN COMPONENT <ls_node>-field_name OF STRUCTURE <ls_hierarchy> TO FIELD-SYMBOL(<lv_node>).

        READ TABLE lt_open_nodes INTO DATA(ls_open_node) INDEX lv_tabix.

        IF sy-subrc <> 0 OR ls_open_node-value <> <lv_node>.

          IF lt_open_nodes IS NOT INITIAL.
            DELETE lt_open_nodes FROM lv_tabix TO lines( lt_open_nodes ).
          ENDIF.

          INSERT VALUE #( value = <lv_node> ) INTO lt_open_nodes INDEX lv_tabix ASSIGNING FIELD-SYMBOL(<ls_open_node>).

        ELSE.
          CONTINUE.
        ENDIF.

        IF lv_tabix > 1.
          READ TABLE lt_open_nodes TRANSPORTING node_id INTO DATA(ls_parent_id) INDEX lv_tabix - 1.
        ENDIF.

        CASE <ls_node>-field_name.
          WHEN 'KUNNR'.
            READ TABLE lt_kunnr_desc ASSIGNING FIELD-SYMBOL(<ls_kunnr_desc>) WITH KEY kunnr = <lv_node> BINARY SEARCH.
            IF sy-subrc = 0.
              lv_node_desc = <ls_kunnr_desc>-name1.
              UNASSIGN <ls_kunnr_desc>.
            ENDIF.
            <lv_node> = |{ <lv_node> ALPHA = OUT }|.
          WHEN 'MONAT'.
            READ TABLE lt_monat_desc ASSIGNING FIELD-SYMBOL(<ls_monat_desc>) WITH KEY mnr = <lv_node> BINARY SEARCH.
            IF sy-subrc = 0.
              lv_node_desc = <ls_monat_desc>-ltx.
              UNASSIGN <ls_monat_desc>.
            ENDIF.
          WHEN 'RBUKRS'.
            READ TABLE lt_bukrs_desc ASSIGNING FIELD-SYMBOL(<ls_bukrs_desc>) WITH KEY bukrs = <lv_node> BINARY SEARCH.
            IF sy-subrc = 0.
              lv_node_desc = <ls_bukrs_desc>-butxt.
              UNASSIGN <ls_bukrs_desc>.
            ENDIF.
          WHEN 'DRCRK'.
            CASE <lv_node>.
              WHEN 'H'.
                lv_node_desc = 'Credit'.
              WHEN 'S'.
                lv_node_desc = 'Debit'.
            ENDCASE.
        ENDCASE.

        IF lv_node_desc IS INITIAL.
          lv_node_text = <lv_node>.
        ELSE.
          lv_node_text = |{ <lv_node> } - { lv_node_desc }|.
        ENDIF.

        DATA(ls_node_layout) =  VALUE lvc_s_layn( isfolder = COND #( WHEN lv_tabix = lines( mt_nodes ) THEN ' ' ELSE 'X' ) ).

        IF <ls_node>-icon IS INITIAL.
          ls_node_layout-n_image = ls_node_layout-exp_image = icon_space.
        ELSEIF <ls_node>-field_name = 'DRCRK'.
          CASE <lv_node>.
            WHEN 'H'.
              ls_node_layout-n_image = ls_node_layout-exp_image = icon_sum.
            WHEN 'S'.
              ls_node_layout-n_image = ls_node_layout-exp_image = icon_sum_red.
          ENDCASE.
        ELSE.
          ls_node_layout-n_image = ls_node_layout-exp_image = <ls_node>-icon.
        ENDIF.

        mo_tree->add_node(
          EXPORTING
            i_relat_node_key     = ls_parent_id-node_id
            i_relationship       = cl_gui_column_tree=>relat_last_child
            i_node_text          = lv_node_text
            is_node_layout       = ls_node_layout
            is_outtab_line       = COND #( WHEN lv_tabix = lv_tot_nodes THEN <ls_hierarchy> )
          IMPORTING
            e_new_node_key       = <ls_open_node>-node_id
          EXCEPTIONS
            relat_node_not_found = 1                " Relat Node Key not Found
            node_not_found       = 2                " Node not Found
            OTHERS               = 3
        ).
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.

        CLEAR: ls_parent_id, lv_node_text, lv_node_desc.
        UNASSIGN <ls_open_node>.

      ENDLOOP.

    ENDLOOP.

    mo_tree->update_calculations( ).
    mo_tree->frontend_update( ).

  ENDMETHOD.

  METHOD build_alv.

    DATA(lo_drag_drop) = NEW cl_dragdrop( ).

    lo_drag_drop->add(
      EXPORTING
        flavor          = 'MOVE_ROW'                " Name of Class/Type
        dragsrc         = abap_true                 " ? DragSource
        droptarget      = abap_true                 " ? DropTarget
        effect          = cl_dragdrop=>move         " ? Move/Copy
      EXCEPTIONS
        already_defined = 1                " Behavior Already Contains the Specified Name
        obj_invalid     = 2                " Object Already Invalidated by Destroy
        OTHERS          = 3
    ).
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    lo_drag_drop->get_handle(
      IMPORTING
        handle      = DATA(lv_handle)  " Behavior Handle
      EXCEPTIONS
        obj_invalid = 1                " Object Already Destroyed
        OTHERS      = 2
    ).
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    DATA(lt_fcat) = VALUE lvc_t_fcat(
      ( fieldname = 'ICON' coltext = 'Icon'  icon = abap_true                   )
      ( fieldname = 'DESC' coltext = 'Field'                                    )
      ( fieldname = 'IS_ACTIVE' coltext = 'Active' hotspot = 'X' checkbox = 'X' )
    ).

    DATA(ls_layout) = VALUE lvc_s_layo( cwidth_opt = abap_true
                                        col_opt    = abap_true
                                        no_toolbar = 'X'
                                        s_dragdrop = VALUE #( row_ddid = lv_handle )
    ).

    SET HANDLER drag_row FOR mo_grid.
    SET HANDLER drop_row FOR mo_grid.
    SET HANDLER drop_row_complete FOR mo_grid.
    SET HANDLER handle_hotspot_click FOR mo_grid.

    mo_grid->set_table_for_first_display(
      EXPORTING
        is_layout       = ls_layout
      CHANGING
        it_outtab       = mt_nodes
        it_fieldcatalog = lt_fcat
    ).

  ENDMETHOD.

  METHOD pai_0100.

    CASE iv_ucomm.

      WHEN 'FC_BACK'.

        IF mo_container IS BOUND.
          mo_container->free( ).
        ENDIF.

        LEAVE TO SCREEN 0.


    ENDCASE.
  ENDMETHOD.

ENDCLASS.

START-OF-SELECTION.

  CREATE OBJECT go_app.
  go_app->execute( ).

MODULE status_0100 OUTPUT.

  SET PF-STATUS 'PF_STATUS_100'.
  SET TITLEBAR  'TITLEBAR_0100'.

ENDMODULE.

MODULE user_command_0100 INPUT.

  go_app->pai_0100( iv_ucomm = sy-ucomm ).

ENDMODULE.
