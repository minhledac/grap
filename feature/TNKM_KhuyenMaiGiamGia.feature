Feature: TNKM_KhuyenMai-GiamGia

  As a tester
  I want to
  So I can

  @TN_KM_01
  Scenario: TN_KM_01
    Given Setup Test Case 
    When Tao don hang tren UI
    | table  | list_pr_code |
    | Bàn TN_KMTT_01     | HTMHTN0202 |
    And Kiem tra icon hop qua khuyen mai
    And Click icon hop qua
    And Kiem tra thong tin chuong trinh khuyen mai tren popup
    | name_promotion  |
    | Khuyến mại 01 |
    And Ap dung chuong trinh khuyen mai
    And Kiem tra thong tin chuong trinh khuyen mai duoc ap dung
    And Click vao button thanh toan don
    Then Assert don hang ap dung chuong trinh khuyen mai
    | GiamGia |
    | 10000 |
    And Teardown test Case

    @TN_KM_02
    Scenario: TN_KM_02
      Given Setup Test Case
      When Tao don hang tren UI
      And Ap dung chuong trinh khuyen mai nhieu dieu kien
      And Thanh toan don hang
      Then Assert thong tin khuyen mai
