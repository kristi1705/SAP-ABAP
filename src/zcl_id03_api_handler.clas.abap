class ZCL_ID03_API_HANDLER definition
  public
  inheriting from CL_REST_HTTP_HANDLER
  final
  create public .

public section.

  methods IF_REST_APPLICATION~GET_ROOT_HANDLER
    redefinition .
protected section.

  methods HANDLE_CSRF_TOKEN
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_ID03_API_HANDLER IMPLEMENTATION.


  method HANDLE_CSRF_TOKEN.
*CALL METHOD SUPER->HANDLE_CSRF_TOKEN
*  EXPORTING
*    IO_CSRF_HANDLER =
*    IO_REQUEST      =
*    IO_RESPONSE     =
*    .
  endmethod.


  method IF_REST_APPLICATION~GET_ROOT_HANDLER.
*CALL METHOD SUPER->IF_REST_APPLICATION~GET_ROOT_HANDLER
*  RECEIVING
*    RO_ROOT_HANDLER =
*    .

    DATA(lo_router) = NEW cl_rest_router( ).
    lo_router->attach( iv_template = '/ZKPTEST' iv_handler_class = 'ZCL_ID03_API' ).
    ro_root_handler = lo_router.

  endmethod.
ENDCLASS.
