Feature: GRAB_DongBoDonHang-Danh Muc Hang Hoa



      @GRAB_DB01
      Scenario Outline:  Don hang binh thuong khong bi loi
        Given Tao 1 tai khoan admin
        When Login vao MHTN
        And Tao 1 don hang binh thuong tren GF
        And Chon ban bang cach tim kiem <Ten_Ban>
        Then Assert thong tin don hang tren GF voi thong tin don hang tren KV

Examples: A
    Documentation for
    |  Ten_Ban   |
    |  Grab Food |


      @GRAB_DB02
      Scenario Outline:  Don hang bi loi
        Given Tao 1 tai khoan admin
        When Login vao MHTN
        And Tao 1 don hang bi loi tren GF
        And Chon ban bang cach tim kiem <Ten_Ban>
        Then Assert thong tin don hang tren GF voi thong tin don hang tren KV

Examples: A
    Documentation for
    |  Ten_Ban   |
    |  Grab Food |


      @GRAB_DB03
      Scenario Outline:  Don hang co ap dung KM tren GF
        Given Tao 1 tai khoan admin
        When Login vao MHTN
        And Tao 1 don hang co ap dung KM tren GF
        And Chon ban bang cach tim kiem <Ten_Ban>
        Then Assert thong tin don hang tren GF voi thong tin don hang tren KV

Examples: A
    Documentation for
    |  Ten_Ban   |
    |  Grab Food |


      @GRAB_DB04
      Scenario Outline:  Don hang co topping tren GF
        Given Tao 1 tai khoan admin
        When Login vao MHTN
        And Tao 1 don hang co topping tren GF
        And Chon ban bang cach tim kiem <Ten_Ban>
        Then Assert thong tin don hang tren GF voi thong tin don hang tren KV

Examples: A
  Documentation for
  |  Ten_Ban   |
  |  Grab Food |


    @GRAB_DB05
    Scenario Outline:  Don hang GF tung dong bo ve KV
      Given Tao 1 tai khoan admin
      When Login vao MHTN
      And Tao 1 don hang co topping tren GF
      And Chon ban bang cach tim kiem <Ten_Ban>
      Then Assert thong tin don hang tren GF voi thong tin don hang tren KV
      When Them 1 mon an vao don hang vua tao tren GF
      Then Assert thong tin don hang tren GF voi thong tin don hang tren KV

Examples: A
Documentation for
|  Ten_Ban   |
|  Grab Food |
