Feature: GRAB_ChonNhomHang-Danh Muc Hang Hoa


    @GRAB_NH01
    Scenario Outline:  co nhieu level nhom hang
      Given Setup Test Case
      When Click Popup chon nhom hang
      And Click <Nhom_hang>
      Then popup chon nhom hang close
      Then Nhom hang hien thi trong DS hang lien ket

Examples: A
    Documentation for
    |  Nhom_hang   |
    |  Nhóm hàng 1 |


    @GRAB_NH02
    Scenario Outline: Nhom hang khong co hang hoa nao
      Given Setup Test Case
      When Click Popup chon nhom hang
      And Click <Nhom_hang>
      Then popup chon nhom hang close
      Then Nhom hang khong hien thi trong DS hang lien ket

Examples: A
    Documentation for
    |  Nhom_hang   |
    |  Nhóm hàng 2 |


      @GRAB_NH03
      Scenario Outline: Nhom hang gom hang ngung hoat dong, hang dich vu, hang bi xoa
        Given Setup Test Case
        When Click Popup chon nhom hang
        And Click <Nhom_hang>
        Then popup chon nhom hang close
        Then Nhom hang khong hien thi trong DS hang lien ket

Examples: A
    Documentation for
    |  Nhom_hang   |
    |  Nhóm hàng 3 |


      @GRAB_NH04
      Scenario Outline: gom hang co topping
        Given Setup Test Case
        When Click Popup chon nhom hang
        And Click <Nhom_hang>
        Then popup chon nhom hang close
        Then Nhom hang hien thi trong DS hang lien ket
        Then Hang hien thi trong DS hang lien ket

Examples: A
    Documentation for
    |  Nhom_hang   |
    |  Nhóm hàng 4 |

    @GRAB_NH05
    Scenario Outline: Keo tha HH trong 1 nhom hang
      Given Setup Test Case
      When Click Popup chon nhom hang
      And Click <Nhom_hang>
      Then popup chon nhom hang close
      Then Nhom hang hien thi trong DS hang lien ket
      When Click chuot vao <hang1>
      And Keo den vi tri <hang2>
      Then Kiem tra vi tri cac hang vua thay doi

Examples: A
    Documentation for
    |  Nhom_hang   |  hang1 |  hang2     |
    |  Nhóm hàng 4 |  Ma hang1 | Ma hang2 |



    @GRAB_NH06
    Scenario Outline: Keo tha HH khac nhom hang
      Given Setup Test Case
      When Click Popup chon nhom hang
      And Click <Nhom_hang>
      Then popup chon nhom hang close
      Then Nhom hang hien thi trong DS hang lien ket
      When Click chuot vao <hang1>
      And Keo den vi tri <hang2>
      Then Kiem tra vi tri cac hang vua thay doi

Examples: A
    Documentation for
    |  Nhom_hang   |  hang1 |  hang2     |
    |  Nhóm hàng 4 |  Ma hang1 | Ma hang2 |


    @GRAB_NH07
    Scenario Outline: Xoa hang, nhom hang lien ket trong DS
      Given Setup Test Case
      When xoa hang khoi danh muc lien ket <hang>
      Then verify thong tin duoc xoa <hang>
      When xoa nhom hang khoi danh muc lien ket <Nhom_hang>
      Then verify thong tin nhom hang duoc xoa <Nhom_hang>

Examples: A
    Documentation for
    |  Nhom_hang   |  hang |
    |  Nhóm hàng 4 |  Ma hang |
