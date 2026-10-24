-- TECHSTORE: Cập nhật ImageURL cho 38 Product theo đúng ProductID trong ảnh DB.
-- Chỉ UPDATE cột ImageURL đang NULL/rỗng. Không tạo bảng, bảng tạm hoặc biến bảng.
-- Dùng thêm ProductName để tránh cập nhật nhầm nếu ID đã bị thay đổi.
-- Các URL đã được kiểm tra tải ảnh ngày 24/10/2026; chưa chạy script trên DB của bạn.

USE [TechStore_PRJ301];
GO

-- 1. iPhone 15 Pro Max 256GB
UPDATE dbo.Product
SET ImageURL = N'https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/iphone-15-pro-max-bluetitanium-select?wid=500&hei=500&fmt=png-alpha'
WHERE ProductID = 1
  AND ProductName = N'iPhone 15 Pro Max 256GB'
  AND (ImageURL IS NULL OR LTRIM(RTRIM(ImageURL)) = N'');

-- 2. iPhone 14 128GB
UPDATE dbo.Product
SET ImageURL = N'https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/iphone-14-blue-select-202209?wid=500&hei=500&fmt=png-alpha'
WHERE ProductID = 2
  AND ProductName = N'iPhone 14 128GB'
  AND (ImageURL IS NULL OR LTRIM(RTRIM(ImageURL)) = N'');

-- 3. iPhone 16 128GB
UPDATE dbo.Product
SET ImageURL = N'https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/iphone-16-ultramarine-select-202409?wid=500&hei=500&fmt=png-alpha'
WHERE ProductID = 3
  AND ProductName = N'iPhone 16 128GB'
  AND (ImageURL IS NULL OR LTRIM(RTRIM(ImageURL)) = N'');

-- 4. Samsung Galaxy S24 Ultra
UPDATE dbo.Product
SET ImageURL = N'https://bizweb.dktcdn.net/thumb/1024x1024/100/525/461/products/image-1730705013631.png?v=1730705018733'
WHERE ProductID = 4
  AND ProductName = N'Samsung Galaxy S24 Ultra'
  AND (ImageURL IS NULL OR LTRIM(RTRIM(ImageURL)) = N'');

-- 5. Samsung Galaxy A55 5G
UPDATE dbo.Product
SET ImageURL = N'https://lcd-phone.com/87116-large_default/samsung-galaxy-a55-5g-256gb-awesome-navy-non-eu-new.jpg'
WHERE ProductID = 5
  AND ProductName = N'Samsung Galaxy A55 5G'
  AND (ImageURL IS NULL OR LTRIM(RTRIM(ImageURL)) = N'');

-- 6. Samsung Galaxy Z Flip5
UPDATE dbo.Product
SET ImageURL = N'https://static.fnac-static.com/multimedia/Images/FR/MDM/d6/cf/51/22138838/3756-1.jpg'
WHERE ProductID = 6
  AND ProductName = N'Samsung Galaxy Z Flip5'
  AND (ImageURL IS NULL OR LTRIM(RTRIM(ImageURL)) = N'');

-- 7. Xiaomi Redmi Note 13 Pro
UPDATE dbo.Product
SET ImageURL = N'https://i02.appmifile.com/13_operatorx_operatorx_opx/11/01/2024/25da829b5997ff8aea28af388df3b8df.png'
WHERE ProductID = 7
  AND ProductName = N'Xiaomi Redmi Note 13 Pro'
  AND (ImageURL IS NULL OR LTRIM(RTRIM(ImageURL)) = N'');

-- 8. Xiaomi 14 256GB
UPDATE dbo.Product
SET ImageURL = N'https://i05.appmifile.com/886_item_uk/07/06/2024/f6882a3273c493e81ddafd8366010e8c.png'
WHERE ProductID = 8
  AND ProductName = N'Xiaomi 14 256GB'
  AND (ImageURL IS NULL OR LTRIM(RTRIM(ImageURL)) = N'');

-- 9. MacBook Air M2 13 inch
UPDATE dbo.Product
SET ImageURL = N'https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/macbook-air-midnight-gallery1-20220606?wid=800&hei=616&fmt=png-alpha'
WHERE ProductID = 9
  AND ProductName = N'MacBook Air M2 13 inch'
  AND (ImageURL IS NULL OR LTRIM(RTRIM(ImageURL)) = N'');

-- 10. MacBook Pro M3 14 inch
UPDATE dbo.Product
SET ImageURL = N'https://iplanet.one/cdn/shop/files/Macbook_Pro_M3_Space_Gray_PDP_Image_Position_1__en-IN.jpg?v=1698726352'
WHERE ProductID = 10
  AND ProductName = N'MacBook Pro M3 14 inch'
  AND (ImageURL IS NULL OR LTRIM(RTRIM(ImageURL)) = N'');

-- 11. Dell XPS 15 9530
UPDATE dbo.Product
SET ImageURL = N'https://mac365.vn/storage/media/import/product/dell-xps-15-9530-2023-h1-6ce7084880.webp'
WHERE ProductID = 11
  AND ProductName = N'Dell XPS 15 9530'
  AND (ImageURL IS NULL OR LTRIM(RTRIM(ImageURL)) = N'');

-- 12. Dell Inspiron 15 3520
UPDATE dbo.Product
SET ImageURL = N'https://www.firstshop.co.za/cdn/shop/files/warmlk-n15adl-2500-1003-pla-hom-traditional-laptops-44895861145764_grande.png?v=1715163952'
WHERE ProductID = 12
  AND ProductName = N'Dell Inspiron 15 3520'
  AND (ImageURL IS NULL OR LTRIM(RTRIM(ImageURL)) = N'');

-- 13. Dell Alienware m16
UPDATE dbo.Product
SET ImageURL = N'https://i.dell.com/is/image/DellContent/content/dam/ss2/product-images/dell-client-products/notebooks/alienware-notebooks/alienware-m16-intel/pdp/laptop-alienware-m16-intel-pdp-hero.psd?fit=constrain%2C1&fmt=png-alpha&hei=400&qlt=95&wid=570'
WHERE ProductID = 13
  AND ProductName = N'Dell Alienware m16'
  AND (ImageURL IS NULL OR LTRIM(RTRIM(ImageURL)) = N'');

-- 14. ASUS ROG Strix G15
UPDATE dbo.Product
SET ImageURL = N'https://dlcdnwebimgs.asus.com/gain/6D1F9EF4-02D6-455B-9D43-348275816538/w1000/h732'
WHERE ProductID = 14
  AND ProductName = N'ASUS ROG Strix G15'
  AND (ImageURL IS NULL OR LTRIM(RTRIM(ImageURL)) = N'');

-- 15. ASUS Zenbook 14 OLED
UPDATE dbo.Product
SET ImageURL = N'https://press.asus.com/assets/w_640%2Ch_640/457342de-a722-4edd-94c9-3a55152b97fd/Zenbook%2014%20OLED_UX3405MA_Product%20photo_3S_Foggy%20Silver_03.PNG'
WHERE ProductID = 15
  AND ProductName = N'ASUS Zenbook 14 OLED'
  AND (ImageURL IS NULL OR LTRIM(RTRIM(ImageURL)) = N'');

-- 16. ASUS Vivobook 15
UPDATE dbo.Product
SET ImageURL = N'https://in.store.asus.com/media/catalog/product/x/1/x1502va_qt_blu_mso_rfrsh_bcklt_kbd_6__1.png?bg-color=255%2C255%2C255&canvas=800%3A800&fit=bounds&height=800&quality=80&width=800'
WHERE ProductID = 16
  AND ProductName = N'ASUS Vivobook 15'
  AND (ImageURL IS NULL OR LTRIM(RTRIM(ImageURL)) = N'');

-- 17. ASUS TUF Gaming A15
UPDATE dbo.Product
SET ImageURL = N'https://images.ekupi.ba/Laptopi/TUFA15_1.jpg'
WHERE ProductID = 17
  AND ProductName = N'ASUS TUF Gaming A15'
  AND (ImageURL IS NULL OR LTRIM(RTRIM(ImageURL)) = N'');

-- 18. HP Pavilion 15
UPDATE dbo.Product
SET ImageURL = N'https://microport.in/cdn/shop/files/7S4N6PA-1_T1682044771_5df324f7-a299-4ffa-9518-bca5713095ef.png?v=1687244306'
WHERE ProductID = 18
  AND ProductName = N'HP Pavilion 15'
  AND (ImageURL IS NULL OR LTRIM(RTRIM(ImageURL)) = N'');

-- 19. HP Envy x360
UPDATE dbo.Product
SET ImageURL = N'https://mcprod.jumbo.ae/media/catalog/product/1/3/13-bf0014ne_b0bpsdslb1.pt02.jpg'
WHERE ProductID = 19
  AND ProductName = N'HP Envy x360'
  AND (ImageURL IS NULL OR LTRIM(RTRIM(ImageURL)) = N'');

-- 20. HP Victus 16
UPDATE dbo.Product
SET ImageURL = N'https://cdn.idealo.com/folder/Product/203054/2/203054201/s1_produktbild_max/hp-victus-16-s0777ng.jpg'
WHERE ProductID = 20
  AND ProductName = N'HP Victus 16'
  AND (ImageURL IS NULL OR LTRIM(RTRIM(ImageURL)) = N'');

-- 21. Lenovo ThinkPad X1 Carbon
UPDATE dbo.Product
SET ImageURL = N'https://product.hstatic.net/200000722513/product/ava_979c41b2a83a4ad6939fd1f3f2d3fbd6.png'
WHERE ProductID = 21
  AND ProductName = N'Lenovo ThinkPad X1 Carbon'
  AND (ImageURL IS NULL OR LTRIM(RTRIM(ImageURL)) = N'');

-- 22. Lenovo Legion 5
UPDATE dbo.Product
SET ImageURL = N'https://www.ietresinformatica.com/media/catalog/product/l/e/legion-5-15ith6h_01_800x800.jpg'
WHERE ProductID = 22
  AND ProductName = N'Lenovo Legion 5'
  AND (ImageURL IS NULL OR LTRIM(RTRIM(ImageURL)) = N'');

-- 23. Lenovo IdeaPad Slim 5
UPDATE dbo.Product
SET ImageURL = N'https://img-prd-pim.poorvika.com/cdn-cgi/image/width%3D500%2Cheight%3D500%2Cquality%3D75/product/lenovo-ideapad-slim-5-intel-core-ultra-5-125h-windows-11-home-laptop-83da008sin-cloud-grey-16gb-1tb-front-view.png'
WHERE ProductID = 23
  AND ProductName = N'Lenovo IdeaPad Slim 5'
  AND (ImageURL IS NULL OR LTRIM(RTRIM(ImageURL)) = N'');

-- 24. Acer Nitro 5
UPDATE dbo.Product
SET ImageURL = N'https://microless.com/cdn/products/42d00d054a46bf5b53b51bf8bba3a855-hi.jpg'
WHERE ProductID = 24
  AND ProductName = N'Acer Nitro 5'
  AND (ImageURL IS NULL OR LTRIM(RTRIM(ImageURL)) = N'');

-- 25. Acer Aspire 5
UPDATE dbo.Product
SET ImageURL = N'https://www.firstshop.co.za/cdn/shop/files/nx-khfea-001-traditional-laptops-42899699957924.png?v=1685692014&width=1214'
WHERE ProductID = 25
  AND ProductName = N'Acer Aspire 5'
  AND (ImageURL IS NULL OR LTRIM(RTRIM(ImageURL)) = N'');

-- 26. AirPods Pro 2 USB-C
UPDATE dbo.Product
SET ImageURL = N'https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/MTJV3?wid=400&hei=400&fmt=png-alpha'
WHERE ProductID = 26
  AND ProductName = N'AirPods Pro 2 USB-C'
  AND (ImageURL IS NULL OR LTRIM(RTRIM(ImageURL)) = N'');

-- 27. Sony WH-1000XM5
UPDATE dbo.Product
SET ImageURL = N'https://www.sony.jp/products/picture/WH-1000XM5.jpg'
WHERE ProductID = 27
  AND ProductName = N'Sony WH-1000XM5'
  AND (ImageURL IS NULL OR LTRIM(RTRIM(ImageURL)) = N'');

-- 28. Sony WF-1000XM5
UPDATE dbo.Product
SET ImageURL = N'https://www.sony.jp/products/picture/WF-1000XM5.jpg'
WHERE ProductID = 28
  AND ProductName = N'Sony WF-1000XM5'
  AND (ImageURL IS NULL OR LTRIM(RTRIM(ImageURL)) = N'');

-- 29. Sony SRS-XB13 Bluetooth
UPDATE dbo.Product
SET ImageURL = N'https://askdirect.co.uk/cdn/shop/files/SRSXB13B.CE7_image_0__95541.1619428631.1280.1280.png?v=1711996213&width=535'
WHERE ProductID = 29
  AND ProductName = N'Sony SRS-XB13 Bluetooth'
  AND (ImageURL IS NULL OR LTRIM(RTRIM(ImageURL)) = N'');

-- 30. Xiaomi Power Bank 10000mAh
UPDATE dbo.Product
SET ImageURL = N'https://i01.appmifile.com/v1/MI_18455B3E4DA706226CF7535A58E875F0267/pms_1678936383.60097709.png'
WHERE ProductID = 30
  AND ProductName = N'Xiaomi Power Bank 10000mAh'
  AND (ImageURL IS NULL OR LTRIM(RTRIM(ImageURL)) = N'');

-- 31. Xiaomi Redmi Buds 5
UPDATE dbo.Product
SET ImageURL = N'https://i02.appmifile.com/735_operatorx_operatorx_opx/11/01/2024/34bf6081e4d7666038873f17cd02eb84.png'
WHERE ProductID = 31
  AND ProductName = N'Xiaomi Redmi Buds 5'
  AND (ImageURL IS NULL OR LTRIM(RTRIM(ImageURL)) = N'');

-- 32. Apple Studio Display 27 inch
UPDATE dbo.Product
SET ImageURL = N'https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/studio-display-gallery-1-202203?wid=600&hei=600&fmt=png-alpha'
WHERE ProductID = 32
  AND ProductName = N'Apple Studio Display 27 inch'
  AND (ImageURL IS NULL OR LTRIM(RTRIM(ImageURL)) = N'');

-- 33. Samsung Odyssey G5 27 inch
UPDATE dbo.Product
SET ImageURL = N'https://fortecia.net/image/cache/wp/gj/reolink/3/com-ua-images-1455151-472756-01-800x800.webp'
WHERE ProductID = 33
  AND ProductName = N'Samsung Odyssey G5 27 inch'
  AND (ImageURL IS NULL OR LTRIM(RTRIM(ImageURL)) = N'');

-- 34. Dell P2422H 24 inch
UPDATE dbo.Product
SET ImageURL = N'https://www.phongcachxanh.vn/cdn/shop/products/man-hinh-dell-24-p2422h-37096244150517.jpg?v=1677139203'
WHERE ProductID = 34
  AND ProductName = N'Dell P2422H 24 inch'
  AND (ImageURL IS NULL OR LTRIM(RTRIM(ImageURL)) = N'');

-- 35. Lenovo L24i Monitor
UPDATE dbo.Product
SET ImageURL = N'https://cdn.idealo.com/folder/Product/201072/0/201072004/s1_produktbild_max/lenovo-l24i-30.jpg'
WHERE ProductID = 35
  AND ProductName = N'Lenovo L24i Monitor'
  AND (ImageURL IS NULL OR LTRIM(RTRIM(ImageURL)) = N'');

-- 36. LG UltraGear 27GR75Q 27 inch
UPDATE dbo.Product
SET ImageURL = N'https://www.lg.com/content/dam/channel/wcms/vn/images/man-hinh-may-tinh/27gr75q-b_atv_eavh_vn_c/27GR75Q-B_ATV_EAVH_VN_C-450x450.jpg'
WHERE ProductID = 36
  AND ProductName = N'LG UltraGear 27GR75Q 27 inch'
  AND (ImageURL IS NULL OR LTRIM(RTRIM(ImageURL)) = N'');

-- 37. LG UltraWide 29WQ600
UPDATE dbo.Product
SET ImageURL = N'https://www.lg.com/content/dam/channel/wcms/vn/images/man-hinh-may-tinh/29wq600-w_atv_eavh_vn_c/29WQ600-W_ATV_EAVH_VN_C-450x450.jpg'
WHERE ProductID = 37
  AND ProductName = N'LG UltraWide 29WQ600'
  AND (ImageURL IS NULL OR LTRIM(RTRIM(ImageURL)) = N'');

-- 38. Acer KA242Y 24 inch
UPDATE dbo.Product
SET ImageURL = N'https://cdn-files.hacom.vn/hacom/cdn/web/23042026/man-hinh-acer-ka242y-p6-moac0153-2.jpg'
WHERE ProductID = 38
  AND ProductName = N'Acer KA242Y 24 inch'
  AND (ImageURL IS NULL OR LTRIM(RTRIM(ImageURL)) = N'');
