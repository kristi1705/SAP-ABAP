class ZCL_IM_KP_CHANGE_ITEM_TEXT definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_EX_ME_PROCESS_PO_CUST .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_KP_CHANGE_ITEM_TEXT IMPLEMENTATION.


  method IF_EX_ME_PROCESS_PO_CUST~CHECK.
  endmethod.


  method IF_EX_ME_PROCESS_PO_CUST~CLOSE.
  endmethod.


  method IF_EX_ME_PROCESS_PO_CUST~FIELDSELECTION_HEADER.
  endmethod.


  method IF_EX_ME_PROCESS_PO_CUST~FIELDSELECTION_HEADER_REFKEYS.
  endmethod.


  method IF_EX_ME_PROCESS_PO_CUST~FIELDSELECTION_ITEM.
  endmethod.


  method IF_EX_ME_PROCESS_PO_CUST~FIELDSELECTION_ITEM_REFKEYS.
  endmethod.


  method IF_EX_ME_PROCESS_PO_CUST~INITIALIZE.
  endmethod.


  method IF_EX_ME_PROCESS_PO_CUST~OPEN.
  endmethod.


  method IF_EX_ME_PROCESS_PO_CUST~POST.
  endmethod.


  method IF_EX_ME_PROCESS_PO_CUST~PROCESS_ACCOUNT.
  endmethod.


  METHOD if_ex_me_process_po_cust~process_header.

    CONSTANTS: c_set TYPE string VALUE 'ZKPSUPPLIERS'.

    IF sy-uname = 'THEPR02'.

      DATA(lv_lifnr) = im_header->get_data( )-lifnr.

      SELECT valfrom
       FROM setleaf
       INTO TABLE @DATA(lt_leaf)
       WHERE setname = @c_set
       AND valfrom = @lv_lifnr.

      IF sy-subrc = 0.

        DATA(lt_items) = im_header->get_items( ).

        LOOP AT lt_items ASSIGNING FIELD-SYMBOL(<ls_items>).

          DATA(ls_item) = <ls_items>-item->get_data( ).

          IF ls_item-matnr IS NOT INITIAL AND ls_item-txz01 NS ls_item-matnr.

            CONCATENATE ls_item-txz01 '_' ls_item-matnr INTO ls_item-txz01.
            <ls_items>-item->set_data( im_data = ls_item ).

          ENDIF.

        ENDLOOP.

      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD if_ex_me_process_po_cust~process_item.
  ENDMETHOD.


  method IF_EX_ME_PROCESS_PO_CUST~PROCESS_SCHEDULE.
  endmethod.
ENDCLASS.
