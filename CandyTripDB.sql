CREATE DATABASE CandyTrip;
GO

USE CandyTrip;
GO

-- ============================================
-- 1. РОЛИ ПОЛЬЗОВАТЕЛЕЙ
-- ============================================
CREATE TABLE Roles (
    RoleID INT IDENTITY(1,1) PRIMARY KEY,
    RoleName NVARCHAR(50) NOT NULL UNIQUE,
    Description NVARCHAR(255) NULL
);
GO

INSERT INTO Roles (RoleName, Description) VALUES
(N'Гость', N'Незарегистрированный пользователь'),
(N'Покупатель', N'Зарегистрированный покупатель'),
(N'Игрок', N'Активный участник мини-игр'),
(N'Администратор', N'Управление каталогом, заказами и филиалами');
GO

-- ============================================
-- 2. ПОЛЬЗОВАТЕЛИ
-- ============================================
CREATE TABLE Users (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    RoleID INT NOT NULL DEFAULT 2,
    FirstName NVARCHAR(100) NOT NULL,
    LastName NVARCHAR(100) NOT NULL,
    Email NVARCHAR(255) NOT NULL UNIQUE,
    Phone NVARCHAR(20) NULL,
    PasswordHash NVARCHAR(512) NOT NULL,
    BirthDate DATE NULL,
    Gender NVARCHAR(10) NULL CHECK (Gender IN (N'Мужской', N'Женский', N'Другое')),
    AvatarURL NVARCHAR(500) NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    TwoFactorEnabled BIT NOT NULL DEFAULT 0,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    UpdatedAt DATETIME2 NULL,
    LastLoginAt DATETIME2 NULL,
    CONSTRAINT FK_Users_Roles FOREIGN KEY (RoleID) REFERENCES Roles(RoleID)
);
GO

CREATE INDEX IX_Users_Email ON Users(Email);
CREATE INDEX IX_Users_RoleID ON Users(RoleID);
GO

-- ============================================
-- 3. АДРЕСА ПОЛЬЗОВАТЕЛЕЙ
-- ============================================
CREATE TABLE UserAddresses (
    AddressID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    AddressType NVARCHAR(20) NOT NULL DEFAULT N'Доставка' CHECK (AddressType IN (N'Доставка', N'Пункт выдачи')),
    City NVARCHAR(100) NOT NULL,
    Street NVARCHAR(200) NOT NULL,
    House NVARCHAR(20) NOT NULL,
    Apartment NVARCHAR(20) NULL,
    PostalCode NVARCHAR(10) NULL,
    IsDefault BIT NOT NULL DEFAULT 0,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_UserAddresses_Users FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE
);
GO

CREATE INDEX IX_UserAddresses_UserID ON UserAddresses(UserID);
GO

-- ============================================
-- 4. КАТЕГОРИИ ТОВАРОВ
-- ============================================
CREATE TABLE Categories (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    ParentCategoryID INT NULL,
    CategoryName NVARCHAR(100) NOT NULL,
    Slug NVARCHAR(100) NOT NULL UNIQUE,
    Description NVARCHAR(500) NULL,
    ImageURL NVARCHAR(500) NULL,
    SortOrder INT NOT NULL DEFAULT 0,
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_Categories_Parent FOREIGN KEY (ParentCategoryID) REFERENCES Categories(CategoryID)
);
GO

INSERT INTO Categories (CategoryName, Slug, Description, SortOrder) VALUES
(N'Мармелад', N'marmalade', N'Жевательный мармелад всех видов', 1),
(N'Шоколад', N'chocolate', N'Шоколадные изделия', 2),
(N'Конфеты', N'candies', N'Леденцы, вата, шоколадные конфеты', 3),
(N'Экзотические фрукты', N'exotic-fruits', N'Сушеные и вяленые экзотические фрукты', 4),
(N'Пирожные', N'cakes', N'Пирожные и десерты', 5),
(N'Тортики', N'torty', N'Торты и тортики', 6);
GO

-- ============================================
-- 5. БРЕНДЫ / ПРОИЗВОДИТЕЛИ
-- ============================================
CREATE TABLE Brands (
    BrandID INT IDENTITY(1,1) PRIMARY KEY,
    BrandName NVARCHAR(150) NOT NULL,
    Country NVARCHAR(100) NULL,
    Description NVARCHAR(500) NULL,
    LogoURL NVARCHAR(500) NULL,
    IsActive BIT NOT NULL DEFAULT 1
);
GO

-- ============================================
-- 6. ТОВАРЫ
-- ============================================
CREATE TABLE Products (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryID INT NOT NULL,
    BrandID INT NULL,
    ProductName NVARCHAR(200) NOT NULL,
    Slug NVARCHAR(200) NOT NULL UNIQUE,
    Description NVARCHAR(MAX) NULL,
    ShortDescription NVARCHAR(500) NULL,
    Price DECIMAL(10,2) NOT NULL CHECK (Price >= 0),
    OldPrice DECIMAL(10,2) NULL,
    CostPrice DECIMAL(10,2) NULL,
    SKU NVARCHAR(50) NULL UNIQUE,
    StockQuantity INT NOT NULL DEFAULT 0,
    WeightGram INT NULL,
    CountryOfOrigin NVARCHAR(100) NULL,
    IsExotic BIT NOT NULL DEFAULT 0,
    IsSpicy BIT NOT NULL DEFAULT 0,
    IsSour BIT NOT NULL DEFAULT 0,
    IsNew BIT NOT NULL DEFAULT 0,
    IsActive BIT NOT NULL DEFAULT 1,
    Rating DECIMAL(3,2) NOT NULL DEFAULT 0,
    ReviewCount INT NOT NULL DEFAULT 0,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    UpdatedAt DATETIME2 NULL,
    CONSTRAINT FK_Products_Categories FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID),
    CONSTRAINT FK_Products_Brands FOREIGN KEY (BrandID) REFERENCES Brands(BrandID)
);
GO

CREATE INDEX IX_Products_CategoryID ON Products(CategoryID);
CREATE INDEX IX_Products_BrandID ON Products(BrandID);
CREATE INDEX IX_Products_Price ON Products(Price);
CREATE INDEX IX_Products_IsActive ON Products(IsActive);
GO

-- ============================================
-- 7. ИЗОБРАЖЕНИЯ ТОВАРОВ
-- ============================================
CREATE TABLE ProductImages (
    ImageID INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT NOT NULL,
    ImageURL NVARCHAR(500) NOT NULL,
    AltText NVARCHAR(200) NULL,
    IsMain BIT NOT NULL DEFAULT 0,
    SortOrder INT NOT NULL DEFAULT 0,
    CONSTRAINT FK_ProductImages_Products FOREIGN KEY (ProductID) REFERENCES Products(ProductID) ON DELETE CASCADE
);
GO

CREATE INDEX IX_ProductImages_ProductID ON ProductImages(ProductID);
GO

-- ============================================
-- 8. ТЕГИ ТОВАРОВ
-- ============================================
CREATE TABLE Tags (
    TagID INT IDENTITY(1,1) PRIMARY KEY,
    TagName NVARCHAR(50) NOT NULL UNIQUE,
    ColorHex NVARCHAR(7) NULL DEFAULT '#CCCCCC'
);
GO

CREATE TABLE ProductTags (
    ProductID INT NOT NULL,
    TagID INT NOT NULL,
    PRIMARY KEY (ProductID, TagID),
    CONSTRAINT FK_ProductTags_Products FOREIGN KEY (ProductID) REFERENCES Products(ProductID) ON DELETE CASCADE,
    CONSTRAINT FK_ProductTags_Tags FOREIGN KEY (TagID) REFERENCES Tags(TagID) ON DELETE CASCADE
);
GO

-- ============================================
-- 9. ОТЗЫВЫ
-- ============================================
CREATE TABLE Reviews (
    ReviewID INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT NOT NULL,
    UserID INT NOT NULL,
    Rating INT NOT NULL CHECK (Rating BETWEEN 1 AND 5),
    Comment NVARCHAR(1000) NULL,
    IsApproved BIT NOT NULL DEFAULT 0,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_Reviews_Products FOREIGN KEY (ProductID) REFERENCES Products(ProductID) ON DELETE CASCADE,
    CONSTRAINT FK_Reviews_Users FOREIGN KEY (UserID) REFERENCES Users(UserID)
);
GO

CREATE INDEX IX_Reviews_ProductID ON Reviews(ProductID);
CREATE INDEX IX_Reviews_UserID ON Reviews(UserID);
GO

-- ============================================
-- 10. КОРЗИНА
-- ============================================
CREATE TABLE Carts (
    CartID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NULL,
    SessionID NVARCHAR(100) NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    UpdatedAt DATETIME2 NULL,
    CONSTRAINT FK_Carts_Users FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE
);
GO

CREATE TABLE CartItems (
    CartItemID INT IDENTITY(1,1) PRIMARY KEY,
    CartID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL DEFAULT 1 CHECK (Quantity > 0),
    AddedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_CartItems_Carts FOREIGN KEY (CartID) REFERENCES Carts(CartID) ON DELETE CASCADE,
    CONSTRAINT FK_CartItems_Products FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);
GO

CREATE INDEX IX_CartItems_CartID ON CartItems(CartID);
GO

-- ============================================
-- 11. ПРОМОКОДЫ
-- ============================================
CREATE TABLE PromoCodes (
    PromoCodeID INT IDENTITY(1,1) PRIMARY KEY,
    Code NVARCHAR(50) NOT NULL UNIQUE,
    DiscountPercent INT NOT NULL CHECK (DiscountPercent BETWEEN 1 AND 100),
    MaxDiscountAmount DECIMAL(10,2) NULL,
    MinOrderAmount DECIMAL(10,2) NULL DEFAULT 0,
    UsageLimit INT NULL,
    UsedCount INT NOT NULL DEFAULT 0,
    ValidFrom DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    ValidTo DATETIME2 NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    Source NVARCHAR(50) NULL DEFAULT N'Игра',
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE INDEX IX_PromoCodes_Code ON PromoCodes(Code);
GO

-- ============================================
-- 12. ИГРЫ
-- ============================================
CREATE TABLE Games (
    GameID INT IDENTITY(1,1) PRIMARY KEY,
    GameName NVARCHAR(100) NOT NULL,
    Slug NVARCHAR(100) NOT NULL UNIQUE,
    Description NVARCHAR(500) NULL,
    IconURL NVARCHAR(500) NULL,
    TargetScore INT NOT NULL DEFAULT 1000,
    TimeLimitSeconds INT NOT NULL DEFAULT 60,
    PromoCodeTemplate NVARCHAR(50) NULL,
    IsActive BIT NOT NULL DEFAULT 1
);
GO

INSERT INTO Games (GameName, Slug, Description, TargetScore, TimeLimitSeconds, PromoCodeTemplate) VALUES
(N'Три в ряд', N'match3', N'Соберите три и более одинаковых конфет в ряд', 1000, 60, N'SWEET15'),
(N'Пасьянс', N'solitaire', N'Классический пасьянс с конфетной тематикой', 500, 120, N'CANDY10'),
(N'Филлворды', N'fillwords', N'Найдите все слова на игровом поле', 300, 90, N'TRIP20');
GO

-- ============================================
-- 13. СЕССИИ ИГР
-- ============================================
CREATE TABLE GameSessions (
    SessionID INT IDENTITY(1,1) PRIMARY KEY,
    GameID INT NOT NULL,
    UserID INT NULL,
    GuestToken NVARCHAR(100) NULL,
    Score INT NOT NULL DEFAULT 0,
    IsWin BIT NOT NULL DEFAULT 0,
    PromoCodeID INT NULL,
    StartedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    FinishedAt DATETIME2 NULL,
    DurationSeconds INT NULL,
    CONSTRAINT FK_GameSessions_Games FOREIGN KEY (GameID) REFERENCES Games(GameID),
    CONSTRAINT FK_GameSessions_Users FOREIGN KEY (UserID) REFERENCES Users(UserID),
    CONSTRAINT FK_GameSessions_PromoCodes FOREIGN KEY (PromoCodeID) REFERENCES PromoCodes(PromoCodeID)
);
GO

CREATE INDEX IX_GameSessions_UserID ON GameSessions(UserID);
CREATE INDEX IX_GameSessions_GameID ON GameSessions(GameID);
GO

-- ============================================
-- 14. ФИЛИАЛЫ / МАГАЗИНЫ
-- ============================================
CREATE TABLE Stores (
    StoreID INT IDENTITY(1,1) PRIMARY KEY,
    StoreName NVARCHAR(150) NOT NULL,
    City NVARCHAR(100) NOT NULL,
    Street NVARCHAR(200) NOT NULL,
    House NVARCHAR(20) NOT NULL,
    PostalCode NVARCHAR(10) NULL,
    Phone NVARCHAR(20) NULL,
    Email NVARCHAR(255) NULL,
    Latitude DECIMAL(9,6) NOT NULL,
    Longitude DECIMAL(9,6) NOT NULL,
    WorkingHours NVARCHAR(100) NULL,
    IsPickupPoint BIT NOT NULL DEFAULT 1,
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE INDEX IX_Stores_City ON Stores(City);
GO

-- ============================================
-- 15. НАЛИЧИЕ ТОВАРОВ В МАГАЗИНАХ
-- ============================================
CREATE TABLE StoreStock (
    StoreStockID INT IDENTITY(1,1) PRIMARY KEY,
    StoreID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL DEFAULT 0,
    ReservedQuantity INT NOT NULL DEFAULT 0,
    UpdatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_StoreStock_Stores FOREIGN KEY (StoreID) REFERENCES Stores(StoreID) ON DELETE CASCADE,
    CONSTRAINT FK_StoreStock_Products FOREIGN KEY (ProductID) REFERENCES Products(ProductID) ON DELETE CASCADE,
    CONSTRAINT UQ_StoreStock UNIQUE (StoreID, ProductID)
);
GO

CREATE INDEX IX_StoreStock_ProductID ON StoreStock(ProductID);
GO

-- ============================================
-- 16. СПОСОБЫ ДОСТАВКИ
-- ============================================
CREATE TABLE DeliveryMethods (
    DeliveryMethodID INT IDENTITY(1,1) PRIMARY KEY,
    MethodName NVARCHAR(100) NOT NULL,
    Description NVARCHAR(500) NULL,
    Price DECIMAL(10,2) NOT NULL DEFAULT 0,
    EstimatedDaysMin INT NULL,
    EstimatedDaysMax INT NULL,
    IsActive BIT NOT NULL DEFAULT 1
);
GO

INSERT INTO DeliveryMethods (MethodName, Description, Price, EstimatedDaysMin, EstimatedDaysMax) VALUES
(N'Самовывоз из ПВЗ', N'Забрать заказ из пункта выдачи', 0, 1, 3),
(N'Курьерская доставка', N'Доставка курьером по адресу', 300, 1, 2);
GO

-- ============================================
-- 17. ЗАКАЗЫ
-- ============================================
CREATE TABLE Orders (
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NULL,
    OrderNumber NVARCHAR(50) NOT NULL UNIQUE,
    Status NVARCHAR(30) NOT NULL DEFAULT N'Ожидает оплаты'
        CHECK (Status IN (N'Ожидает оплаты', N'Оплачен', N'Собирается', N'В доставке', N'Готов к выдаче', N'Выполнен', N'Отменён', N'Возврат')),
    DeliveryMethodID INT NOT NULL,
    StoreID INT NULL,
    AddressID INT NULL,
    PromoCodeID INT NULL,
    SubTotal DECIMAL(10,2) NOT NULL DEFAULT 0,
    DiscountAmount DECIMAL(10,2) NOT NULL DEFAULT 0,
    DeliveryPrice DECIMAL(10,2) NOT NULL DEFAULT 0,
    TotalAmount DECIMAL(10,2) NOT NULL DEFAULT 0,
    CustomerName NVARCHAR(200) NOT NULL,
    CustomerPhone NVARCHAR(20) NOT NULL,
    CustomerEmail NVARCHAR(255) NULL,
    DeliveryAddress NVARCHAR(500) NULL,
    DeliveryDate DATE NULL,
    DeliveryTimeSlot NVARCHAR(50) NULL,
    Comment NVARCHAR(1000) NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    UpdatedAt DATETIME2 NULL,
    PaidAt DATETIME2 NULL,
    CompletedAt DATETIME2 NULL,
    CONSTRAINT FK_Orders_Users FOREIGN KEY (UserID) REFERENCES Users(UserID),
    CONSTRAINT FK_Orders_DeliveryMethods FOREIGN KEY (DeliveryMethodID) REFERENCES DeliveryMethods(DeliveryMethodID),
    CONSTRAINT FK_Orders_Stores FOREIGN KEY (StoreID) REFERENCES Stores(StoreID),
    CONSTRAINT FK_Orders_Addresses FOREIGN KEY (AddressID) REFERENCES UserAddresses(AddressID),
    CONSTRAINT FK_Orders_PromoCodes FOREIGN KEY (PromoCodeID) REFERENCES PromoCodes(PromoCodeID)
);
GO

CREATE INDEX IX_Orders_UserID ON Orders(UserID);
CREATE INDEX IX_Orders_Status ON Orders(Status);
CREATE INDEX IX_Orders_OrderNumber ON Orders(OrderNumber);
CREATE INDEX IX_Orders_CreatedAt ON Orders(CreatedAt);
GO

-- ============================================
-- 18. ПОЗИЦИИ ЗАКАЗА
-- ============================================
CREATE TABLE OrderItems (
    OrderItemID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    ProductName NVARCHAR(200) NOT NULL,
    Quantity INT NOT NULL CHECK (Quantity > 0),
    UnitPrice DECIMAL(10,2) NOT NULL,
    DiscountPercent INT NOT NULL DEFAULT 0,
    TotalPrice DECIMAL(10,2) NOT NULL,
    CONSTRAINT FK_OrderItems_Orders FOREIGN KEY (OrderID) REFERENCES Orders(OrderID) ON DELETE CASCADE,
    CONSTRAINT FK_OrderItems_Products FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);
GO

CREATE INDEX IX_OrderItems_OrderID ON OrderItems(OrderID);
GO

-- ============================================
-- 19. ПЛАТЕЖИ
-- ============================================
CREATE TABLE Payments (
    PaymentID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT NOT NULL,
    PaymentMethod NVARCHAR(30) NOT NULL CHECK (PaymentMethod IN (N'Банковская карта', N'СБП', N'Электронный кошелёк', N'Наличные при получении')),
    PaymentStatus NVARCHAR(30) NOT NULL DEFAULT N'Ожидает'
        CHECK (PaymentStatus IN (N'Ожидает', N'Обработка', N'Успешно', N'Ошибка', N'Возврат')),
    Amount DECIMAL(10,2) NOT NULL,
    TransactionID NVARCHAR(100) NULL,
    CardLast4 NVARCHAR(4) NULL,
    ErrorMessage NVARCHAR(500) NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CompletedAt DATETIME2 NULL,
    CONSTRAINT FK_Payments_Orders FOREIGN KEY (OrderID) REFERENCES Orders(OrderID) ON DELETE CASCADE
);
GO

CREATE INDEX IX_Payments_OrderID ON Payments(OrderID);
CREATE INDEX IX_Payments_Status ON Payments(PaymentStatus);
GO

-- ============================================
-- 20. ПРИВЯЗАННЫЕ КАРТЫ
-- ============================================
CREATE TABLE SavedCards (
    CardID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    CardMask NVARCHAR(20) NOT NULL,
    CardType NVARCHAR(30) NULL,
    ExpiryMonth INT NULL,
    ExpiryYear INT NULL,
    Token NVARCHAR(255) NOT NULL,
    IsDefault BIT NOT NULL DEFAULT 0,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_SavedCards_Users FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE
);
GO

CREATE INDEX IX_SavedCards_UserID ON SavedCards(UserID);
GO

-- ============================================
-- 21. ИСТОРИЯ ЗАКАЗОВ / СТАТУСОВ
-- ============================================
CREATE TABLE OrderStatusHistory (
    HistoryID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT NOT NULL,
    OldStatus NVARCHAR(30) NULL,
    NewStatus NVARCHAR(30) NOT NULL,
    ChangedByUserID INT NULL,
    Comment NVARCHAR(500) NULL,
    ChangedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_OrderStatusHistory_Orders FOREIGN KEY (OrderID) REFERENCES Orders(OrderID) ON DELETE CASCADE,
    CONSTRAINT FK_OrderStatusHistory_Users FOREIGN KEY (ChangedByUserID) REFERENCES Users(UserID)
);
GO

CREATE INDEX IX_OrderStatusHistory_OrderID ON OrderStatusHistory(OrderID);
GO

-- ============================================
-- 22. ИЗБРАННОЕ
-- ============================================
CREATE TABLE Wishlists (
    WishlistID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    ProductID INT NOT NULL,
    AddedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_Wishlists_Users FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE,
    CONSTRAINT FK_Wishlists_Products FOREIGN KEY (ProductID) REFERENCES Products(ProductID) ON DELETE CASCADE,
    CONSTRAINT UQ_Wishlists UNIQUE (UserID, ProductID)
);
GO

-- ============================================
-- 23. ОБРАЩЕНИЯ В ПОДДЕРЖКУ
-- ============================================
CREATE TABLE SupportTickets (
    TicketID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NULL,
    GuestEmail NVARCHAR(255) NULL,
    GuestName NVARCHAR(200) NULL,
    Subject NVARCHAR(200) NOT NULL,
    Message NVARCHAR(MAX) NOT NULL,
    Status NVARCHAR(30) NOT NULL DEFAULT N'Открыт'
        CHECK (Status IN (N'Открыт', N'В обработке', N'Решён', N'Закрыт')),
    Priority NVARCHAR(20) NOT NULL DEFAULT N'Средний'
        CHECK (Priority IN (N'Низкий', N'Средний', N'Высокий')),
    AssignedToUserID INT NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    UpdatedAt DATETIME2 NULL,
    ClosedAt DATETIME2 NULL,
    CONSTRAINT FK_SupportTickets_Users FOREIGN KEY (UserID) REFERENCES Users(UserID),
    CONSTRAINT FK_SupportTickets_Assigned FOREIGN KEY (AssignedToUserID) REFERENCES Users(UserID)
);
GO

CREATE INDEX IX_SupportTickets_UserID ON SupportTickets(UserID);
CREATE INDEX IX_SupportTickets_Status ON SupportTickets(Status);
GO

-- ============================================
-- 24. СООБЩЕНИЯ В ТИКЕТАХ
-- ============================================
CREATE TABLE TicketMessages (
    MessageID INT IDENTITY(1,1) PRIMARY KEY,
    TicketID INT NOT NULL,
    UserID INT NULL,
    Message NVARCHAR(MAX) NOT NULL,
    IsFromSupport BIT NOT NULL DEFAULT 0,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_TicketMessages_Tickets FOREIGN KEY (TicketID) REFERENCES SupportTickets(TicketID) ON DELETE CASCADE,
    CONSTRAINT FK_TicketMessages_Users FOREIGN KEY (UserID) REFERENCES Users(UserID)
);
GO

CREATE INDEX IX_TicketMessages_TicketID ON TicketMessages(TicketID);
GO

-- ============================================
-- 25. ИСТОРИЯ ПРОСМОТРОВ
-- ============================================
CREATE TABLE ViewHistory (
    ViewID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NULL,
    SessionID NVARCHAR(100) NULL,
    ProductID INT NOT NULL,
    ViewedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_ViewHistory_Users FOREIGN KEY (UserID) REFERENCES Users(UserID),
    CONSTRAINT FK_ViewHistory_Products FOREIGN KEY (ProductID) REFERENCES Products(ProductID) ON DELETE CASCADE
);
GO

CREATE INDEX IX_ViewHistory_UserID ON ViewHistory(UserID);
CREATE INDEX IX_ViewHistory_ProductID ON ViewHistory(ProductID);
GO

-- ============================================
-- 26. ЖУРНАЛ ДЕЙСТВИЙ (AUDIT LOG)
-- ============================================
CREATE TABLE AuditLog (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NULL,
    ActionType NVARCHAR(50) NOT NULL,
    EntityType NVARCHAR(50) NULL,
    EntityID INT NULL,
    OldValue NVARCHAR(MAX) NULL,
    NewValue NVARCHAR(MAX) NULL,
    IPAddress NVARCHAR(45) NULL,
    UserAgent NVARCHAR(500) NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_AuditLog_Users FOREIGN KEY (UserID) REFERENCES Users(UserID)
);
GO

CREATE INDEX IX_AuditLog_UserID ON AuditLog(UserID);
CREATE INDEX IX_AuditLog_Entity ON AuditLog(EntityType, EntityID);
CREATE INDEX IX_AuditLog_CreatedAt ON AuditLog(CreatedAt);
GO

-- ============================================
-- 27. НАСТРОЙКИ САЙТА
-- ============================================
CREATE TABLE SiteSettings (
    SettingID INT IDENTITY(1,1) PRIMARY KEY,
    SettingKey NVARCHAR(100) NOT NULL UNIQUE,
    SettingValue NVARCHAR(MAX) NULL,
    Description NVARCHAR(500) NULL,
    UpdatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO

INSERT INTO SiteSettings (SettingKey, SettingValue, Description) VALUES
(N'site_name', N'CandyTrip', N'Название сайта'),
(N'site_email', N'info@candytrip.ru', N'Контактный email'),
(N'site_phone', N'+7 (383) 000-00-00', N'Контактный телефон'),
(N'free_delivery_threshold', N'3000', N'Порог бесплатной доставки'),
(N'default_delivery_price', N'300', N'Стоимость доставки по умолчанию');
GO

-- ============================================
-- 28. ПРОСМОТРЫ / СТАТИСТИКА
-- ============================================
CREATE TABLE PageViews (
    ViewID BIGINT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NULL,
    SessionID NVARCHAR(100) NULL,
    PageURL NVARCHAR(500) NOT NULL,
    Referrer NVARCHAR(500) NULL,
    IPAddress NVARCHAR(45) NULL,
    UserAgent NVARCHAR(500) NULL,
    ViewedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE INDEX IX_PageViews_UserID ON PageViews(UserID);
CREATE INDEX IX_PageViews_ViewedAt ON PageViews(ViewedAt);
GO

-- ============================================
-- 29. КОНВЕРСИИ / МЕТРИКИ
-- ============================================
CREATE TABLE ConversionEvents (
    EventID BIGINT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NULL,
    SessionID NVARCHAR(100) NULL,
    EventType NVARCHAR(50) NOT NULL,
    EventValue DECIMAL(10,2) NULL,
    Metadata NVARCHAR(MAX) NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE INDEX IX_ConversionEvents_EventType ON ConversionEvents(EventType);
CREATE INDEX IX_ConversionEvents_CreatedAt ON ConversionEvents(CreatedAt);
GO

-- ============================================
-- 30. СКИДКИ / АКЦИИ
-- ============================================
CREATE TABLE Discounts (
    DiscountID INT IDENTITY(1,1) PRIMARY KEY,
    DiscountName NVARCHAR(200) NOT NULL,
    DiscountType NVARCHAR(20) NOT NULL CHECK (DiscountType IN (N'Процент', N'Фиксированная')),
    DiscountValue DECIMAL(10,2) NOT NULL,
    CategoryID INT NULL,
    ProductID INT NULL,
    MinQuantity INT NULL,
    ValidFrom DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    ValidTo DATETIME2 NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    CONSTRAINT FK_Discounts_Categories FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID),
    CONSTRAINT FK_Discounts_Products FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);
GO

-- ============================================
-- 31. УВЕДОМЛЕНИЯ
-- ============================================
CREATE TABLE Notifications (
    NotificationID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    Title NVARCHAR(200) NOT NULL,
    Message NVARCHAR(1000) NOT NULL,
    NotificationType NVARCHAR(50) NULL,
    IsRead BIT NOT NULL DEFAULT 0,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    ReadAt DATETIME2 NULL,
    CONSTRAINT FK_Notifications_Users FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE
);
GO

CREATE INDEX IX_Notifications_UserID ON Notifications(UserID);
CREATE INDEX IX_Notifications_IsRead ON Notifications(IsRead);
GO

-- ============================================
-- 32. ПОДПИСКИ НА РАССЫЛКУ
-- ============================================
CREATE TABLE NewsletterSubscriptions (
    SubscriptionID INT IDENTITY(1,1) PRIMARY KEY,
    Email NVARCHAR(255) NOT NULL UNIQUE,
    UserID INT NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    SubscribedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    UnsubscribedAt DATETIME2 NULL,
    CONSTRAINT FK_Newsletter_Users FOREIGN KEY (UserID) REFERENCES Users(UserID)
);
GO

-- ============================================
-- 33. КУПОНЫ ПОЛЬЗОВАТЕЛЕЙ
-- ============================================
CREATE TABLE UserCoupons (
    UserCouponID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    PromoCodeID INT NOT NULL,
    IsUsed BIT NOT NULL DEFAULT 0,
    UsedAt DATETIME2 NULL,
    OrderID INT NULL,
    ReceivedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    ExpiresAt DATETIME2 NULL,
    CONSTRAINT FK_UserCoupons_Users FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE,
    CONSTRAINT FK_UserCoupons_PromoCodes FOREIGN KEY (PromoCodeID) REFERENCES PromoCodes(PromoCodeID),
    CONSTRAINT FK_UserCoupons_Orders FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);
GO

CREATE INDEX IX_UserCoupons_UserID ON UserCoupons(UserID);
GO

-- ============================================
-- 34. ЛОГИРОВАНИЕ ОШИБОК
-- ============================================
CREATE TABLE ErrorLog (
    ErrorID BIGINT IDENTITY(1,1) PRIMARY KEY,
    ErrorMessage NVARCHAR(MAX) NOT NULL,
    StackTrace NVARCHAR(MAX) NULL,
    UserID INT NULL,
    PageURL NVARCHAR(500) NULL,
    Severity NVARCHAR(20) NULL DEFAULT N'Error',
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_ErrorLog_Users FOREIGN KEY (UserID) REFERENCES Users(UserID)
);
GO

CREATE INDEX IX_ErrorLog_CreatedAt ON ErrorLog(CreatedAt);
GO

-- ============================================
-- 35. СЕССИИ ПОЛЬЗОВАТЕЛЕЙ
-- ============================================
CREATE TABLE UserSessions (
    SessionID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NULL,
    SessionToken NVARCHAR(255) NOT NULL UNIQUE,
    IPAddress NVARCHAR(45) NULL,
    UserAgent NVARCHAR(500) NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    ExpiresAt DATETIME2 NOT NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    CONSTRAINT FK_UserSessions_Users FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE
);
GO

CREATE INDEX IX_UserSessions_Token ON UserSessions(SessionToken);
CREATE INDEX IX_UserSessions_UserID ON UserSessions(UserID);
GO

-- ============================================
-- 36. СБРОС ПАРОЛЯ
-- ============================================
CREATE TABLE PasswordResets (
    ResetID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    ResetToken NVARCHAR(255) NOT NULL UNIQUE,
    ExpiresAt DATETIME2 NOT NULL,
    IsUsed BIT NOT NULL DEFAULT 0,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_PasswordResets_Users FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE
);
GO

-- ============================================
-- 37. ПОДТВЕРЖДЕНИЕ EMAIL
-- ============================================
CREATE TABLE EmailConfirmations (
    ConfirmationID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    ConfirmationToken NVARCHAR(255) NOT NULL UNIQUE,
    ExpiresAt DATETIME2 NOT NULL,
    IsConfirmed BIT NOT NULL DEFAULT 0,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_EmailConfirmations_Users FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE
);
GO

-- ============================================
-- 38. ДВУХФАКТОРНАЯ АУТЕНТИФИКАЦИЯ
-- ============================================
CREATE TABLE TwoFactorAuth (
    TwoFactorID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL UNIQUE,
    SecretKey NVARCHAR(255) NOT NULL,
    IsEnabled BIT NOT NULL DEFAULT 0,
    BackupCodes NVARCHAR(MAX) NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    UpdatedAt DATETIME2 NULL,
    CONSTRAINT FK_TwoFactorAuth_Users FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE
);
GO

-- ============================================
-- 39. ЛОГИ ВХОДА
-- ============================================
CREATE TABLE LoginAttempts (
    AttemptID BIGINT IDENTITY(1,1) PRIMARY KEY,
    Email NVARCHAR(255) NOT NULL,
    IPAddress NVARCHAR(45) NULL,
    UserAgent NVARCHAR(500) NULL,
    IsSuccess BIT NOT NULL,
    FailureReason NVARCHAR(200) NULL,
    AttemptedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE INDEX IX_LoginAttempts_Email ON LoginAttempts(Email);
CREATE INDEX IX_LoginAttempts_AttemptedAt ON LoginAttempts(AttemptedAt);
GO

-- ============================================
-- 40. API КЛЮЧИ
-- ============================================
CREATE TABLE ApiKeys (
    ApiKeyID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NULL,
    ApiKey NVARCHAR(255) NOT NULL UNIQUE,
    ApiSecret NVARCHAR(255) NOT NULL,
    Permissions NVARCHAR(MAX) NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    ExpiresAt DATETIME2 NULL,
    LastUsedAt DATETIME2 NULL,
    CONSTRAINT FK_ApiKeys_Users FOREIGN KEY (UserID) REFERENCES Users(UserID)
);
GO

-- ============================================
-- 41. ЛОГИ WEBHOOK
-- ============================================
CREATE TABLE WebhookLogs (
    WebhookLogID BIGINT IDENTITY(1,1) PRIMARY KEY,
    Source NVARCHAR(100) NOT NULL,
    EventType NVARCHAR(100) NOT NULL,
    Payload NVARCHAR(MAX) NULL,
    ResponseStatus INT NULL,
    ResponseBody NVARCHAR(MAX) NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE INDEX IX_WebhookLogs_Source ON WebhookLogs(Source);
CREATE INDEX IX_WebhookLogs_CreatedAt ON WebhookLogs(CreatedAt);
GO

-- ============================================
-- 42. КЭШ КАТАЛОГА (для оптимизации)
-- ============================================
CREATE TABLE CatalogCache (
    CacheID INT IDENTITY(1,1) PRIMARY KEY,
    CacheKey NVARCHAR(255) NOT NULL UNIQUE,
    CacheValue NVARCHAR(MAX) NOT NULL,
    ExpiresAt DATETIME2 NOT NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO

-- ============================================
-- 43. РЕКОМЕНДАЦИИ
-- ============================================
CREATE TABLE Recommendations (
    RecommendationID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NOT NULL,
    ProductID INT NOT NULL,
    Score DECIMAL(5,4) NOT NULL DEFAULT 0,
    Reason NVARCHAR(200) NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_Recommendations_Users FOREIGN KEY (UserID) REFERENCES Users(UserID) ON DELETE CASCADE,
    CONSTRAINT FK_Recommendations_Products FOREIGN KEY (ProductID) REFERENCES Products(ProductID) ON DELETE CASCADE
);
GO

CREATE INDEX IX_Recommendations_UserID ON Recommendations(UserID);
GO

-- ============================================
-- 44. СРАВНЕНИЕ ТОВАРОВ
-- ============================================
CREATE TABLE ProductComparisons (
    ComparisonID INT IDENTITY(1,1) PRIMARY KEY,
    UserID INT NULL,
    SessionID NVARCHAR(100) NULL,
    ProductID INT NOT NULL,
    AddedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_ProductComparisons_Users FOREIGN KEY (UserID) REFERENCES Users(UserID),
    CONSTRAINT FK_ProductComparisons_Products FOREIGN KEY (ProductID) REFERENCES Products(ProductID) ON DELETE CASCADE
);
GO

-- ============================================
-- 45. ЖУРНАЛ ИМПОРТА / ЭКСПОРТА
-- ============================================
CREATE TABLE ImportExportLogs (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    OperationType NVARCHAR(20) NOT NULL CHECK (OperationType IN (N'Импорт', N'Экспорт')),
    EntityType NVARCHAR(50) NOT NULL,
    FileName NVARCHAR(255) NULL,
    RecordsCount INT NULL,
    Status NVARCHAR(30) NOT NULL,
    ErrorMessage NVARCHAR(MAX) NULL,
    StartedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    FinishedAt DATETIME2 NULL,
    UserID INT NULL,
    CONSTRAINT FK_ImportExportLogs_Users FOREIGN KEY (UserID) REFERENCES Users(UserID)
);
GO

-- ============================================
-- 46. ГЕОЛОКАЦИИ (КЭШ)
-- ============================================
CREATE TABLE GeoCache (
    GeoCacheID INT IDENTITY(1,1) PRIMARY KEY,
    IPAddress NVARCHAR(45) NOT NULL UNIQUE,
    City NVARCHAR(100) NULL,
    Region NVARCHAR(100) NULL,
    Country NVARCHAR(100) NULL,
    Latitude DECIMAL(9,6) NULL,
    Longitude DECIMAL(9,6) NULL,
    UpdatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO

-- ============================================
-- 47. КУРСЫ ВАЛЮТ
-- ============================================
CREATE TABLE CurrencyRates (
    RateID INT IDENTITY(1,1) PRIMARY KEY,
    CurrencyCode NVARCHAR(3) NOT NULL,
    RateToRUB DECIMAL(12,6) NOT NULL,
    UpdatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO

INSERT INTO CurrencyRates (CurrencyCode, RateToRUB) VALUES
(N'USD', 92.500000),
(N'EUR', 100.200000),
(N'JPY', 0.620000),
(N'CNY', 12.800000);
GO

-- ============================================
-- 48. КОНТЕНТ СТРАНИЦ (CMS)
-- ============================================
CREATE TABLE PageContents (
    ContentID INT IDENTITY(1,1) PRIMARY KEY,
    PageSlug NVARCHAR(100) NOT NULL UNIQUE,
    Title NVARCHAR(200) NOT NULL,
    Content NVARCHAR(MAX) NULL,
    MetaDescription NVARCHAR(500) NULL,
    MetaKeywords NVARCHAR(500) NULL,
    IsPublished BIT NOT NULL DEFAULT 1,
    UpdatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO

INSERT INTO PageContents (PageSlug, Title, Content) VALUES
(N'about', N'О нас', N'CandyTrip — магазин оригинальных сладостей со всего мира.'),
(N'contacts', N'Контакты', N'Свяжитесь с нами по телефону или email.'),
(N'delivery', N'Доставка', N'Информация о доставке и оплате.');
GO

-- ============================================
-- 49. БАННЕРЫ
-- ============================================
CREATE TABLE Banners (
    BannerID INT IDENTITY(1,1) PRIMARY KEY,
    Title NVARCHAR(200) NULL,
    ImageURL NVARCHAR(500) NOT NULL,
    LinkURL NVARCHAR(500) NULL,
    Position NVARCHAR(50) NOT NULL DEFAULT N'Главная',
    SortOrder INT NOT NULL DEFAULT 0,
    ValidFrom DATETIME2 NULL,
    ValidTo DATETIME2 NULL,
    IsActive BIT NOT NULL DEFAULT 1
);
GO

-- ============================================
-- 50. FAQ
-- ============================================
CREATE TABLE FAQ (
    FAQID INT IDENTITY(1,1) PRIMARY KEY,
    Question NVARCHAR(500) NOT NULL,
    Answer NVARCHAR(MAX) NOT NULL,
    Category NVARCHAR(100) NULL,
    SortOrder INT NOT NULL DEFAULT 0,
    IsActive BIT NOT NULL DEFAULT 1
);
GO

-- ============================================
-- ПРЕДСТАВЛЕНИЯ (VIEWS)
-- ============================================

CREATE VIEW vw_ActiveProducts AS
SELECT 
    p.ProductID,
    p.ProductName,
    p.Slug,
    p.Price,
    p.OldPrice,
    p.StockQuantity,
    p.Rating,
    p.ReviewCount,
    p.IsExotic,
    p.IsSpicy,
    p.IsSour,
    c.CategoryName,
    c.Slug AS CategorySlug,
    b.BrandName,
    b.Country
FROM Products p
INNER JOIN Categories c ON p.CategoryID = c.CategoryID
LEFT JOIN Brands b ON p.BrandID = b.BrandID
WHERE p.IsActive = 1 AND p.StockQuantity > 0;
GO

CREATE VIEW vw_UserOrders AS
SELECT 
    o.OrderID,
    o.OrderNumber,
    o.Status,
    o.TotalAmount,
    o.CreatedAt,
    u.FirstName + N' ' + u.LastName AS CustomerName,
    u.Email,
    u.Phone,
    dm.MethodName AS DeliveryMethod,
    s.StoreName,
    (SELECT COUNT(*) FROM OrderItems oi WHERE oi.OrderID = o.OrderID) AS ItemCount
FROM Orders o
LEFT JOIN Users u ON o.UserID = u.UserID
INNER JOIN DeliveryMethods dm ON o.DeliveryMethodID = dm.DeliveryMethodID
LEFT JOIN Stores s ON o.StoreID = s.StoreID;
GO

CREATE VIEW vw_ProductReviews AS
SELECT 
    r.ReviewID,
    p.ProductName,
    u.FirstName + N' ' + u.LastName AS UserName,
    r.Rating,
    r.Comment,
    r.IsApproved,
    r.CreatedAt
FROM Reviews r
INNER JOIN Products p ON r.ProductID = p.ProductID
INNER JOIN Users u ON r.UserID = u.UserID;
GO

CREATE VIEW vw_GameStats AS
SELECT 
    g.GameName,
    COUNT(gs.SessionID) AS TotalSessions,
    SUM(CASE WHEN gs.IsWin = 1 THEN 1 ELSE 0 END) AS Wins,
    AVG(gs.Score) AS AvgScore,
    MAX(gs.Score) AS MaxScore
FROM Games g
LEFT JOIN GameSessions gs ON g.GameID = gs.GameID
GROUP BY g.GameName;
GO

CREATE VIEW vw_StoreAvailability AS
SELECT 
    s.StoreName,
    s.City,
    s.Street + N', ' + s.House AS Address,
    p.ProductName,
    ss.Quantity,
    ss.Quantity - ss.ReservedQuantity AS AvailableQuantity
FROM StoreStock ss
INNER JOIN Stores s ON ss.StoreID = s.StoreID
INNER JOIN Products p ON ss.ProductID = p.ProductID
WHERE ss.Quantity > 0;
GO

-- ============================================
-- ХРАНИМЫЕ ПРОЦЕДУРЫ
-- ============================================

CREATE PROCEDURE sp_GetUserCart
    @UserID INT
AS
BEGIN
    SELECT 
        ci.CartItemID,
        p.ProductID,
        p.ProductName,
        p.Price,
        ci.Quantity,
        p.Price * ci.Quantity AS TotalPrice,
        p.StockQuantity
    FROM CartItems ci
    INNER JOIN Carts c ON ci.CartID = c.CartID
    INNER JOIN Products p ON ci.ProductID = p.ProductID
    WHERE c.UserID = @UserID;
END;
GO

CREATE PROCEDURE sp_AddToCart
    @UserID INT,
    @ProductID INT,
    @Quantity INT = 1
AS
BEGIN
    DECLARE @CartID INT;
    
    SELECT @CartID = CartID FROM Carts WHERE UserID = @UserID;
    
    IF @CartID IS NULL
    BEGIN
        INSERT INTO Carts (UserID) VALUES (@UserID);
        SET @CartID = SCOPE_IDENTITY();
    END
    
    IF EXISTS (SELECT 1 FROM CartItems WHERE CartID = @CartID AND ProductID = @ProductID)
    BEGIN
        UPDATE CartItems 
        SET Quantity = Quantity + @Quantity
        WHERE CartID = @CartID AND ProductID = @ProductID;
    END
    ELSE
    BEGIN
        INSERT INTO CartItems (CartID, ProductID, Quantity)
        VALUES (@CartID, @ProductID, @Quantity);
    END
    
    UPDATE Carts SET UpdatedAt = SYSDATETIME() WHERE CartID = @CartID;
END;
GO

CREATE PROCEDURE sp_ApplyPromoCode
    @UserID INT,
    @PromoCode NVARCHAR(50),
    @OrderAmount DECIMAL(10,2),
    @DiscountAmount DECIMAL(10,2) OUTPUT
AS
BEGIN
    DECLARE @PromoCodeID INT;
    DECLARE @DiscountPercent INT;
    DECLARE @MaxDiscount DECIMAL(10,2);
    DECLARE @MinOrder DECIMAL(10,2);
    
    SELECT 
        @PromoCodeID = PromoCodeID,
        @DiscountPercent = DiscountPercent,
        @MaxDiscount = MaxDiscountAmount,
        @MinOrder = MinOrderAmount
    FROM PromoCodes
    WHERE Code = @PromoCode 
        AND IsActive = 1
        AND (ValidTo IS NULL OR ValidTo >= SYSDATETIME())
        AND (UsageLimit IS NULL OR UsedCount < UsageLimit);
    
    IF @PromoCodeID IS NULL
    BEGIN
        SET @DiscountAmount = 0;
        RETURN;
    END
    
    IF @OrderAmount < @MinOrder
    BEGIN
        SET @DiscountAmount = 0;
        RETURN;
    END
    
    SET @DiscountAmount = @OrderAmount * @DiscountPercent / 100.0;
    
    IF @MaxDiscount IS NOT NULL AND @DiscountAmount > @MaxDiscount
        SET @DiscountAmount = @MaxDiscount;
    
    UPDATE PromoCodes SET UsedCount = UsedCount + 1 WHERE PromoCodeID = @PromoCodeID;
END;
GO

CREATE PROCEDURE sp_CreateOrder
    @UserID INT,
    @CustomerName NVARCHAR(200),
    @CustomerPhone NVARCHAR(20),
    @CustomerEmail NVARCHAR(255),
    @DeliveryMethodID INT,
    @StoreID INT = NULL,
    @AddressID INT = NULL,
    @PromoCodeID INT = NULL,
    @Comment NVARCHAR(1000) = NULL,
    @OrderID INT OUTPUT
AS
BEGIN
    DECLARE @OrderNumber NVARCHAR(50);
    DECLARE @SubTotal DECIMAL(10,2);
    DECLARE @DiscountAmount DECIMAL(10,2) = 0;
    DECLARE @DeliveryPrice DECIMAL(10,2);
    DECLARE @TotalAmount DECIMAL(10,2);
    
    SET @OrderNumber = N'CT-' + FORMAT(SYSDATETIME(), 'yyyyMMddHHmmss') + N'-' + CAST(ABS(CHECKSUM(NEWID())) % 10000 AS NVARCHAR(4));
    
    SELECT @SubTotal = ISNULL(SUM(ci.Quantity * p.Price), 0)
    FROM CartItems ci
    INNER JOIN Carts c ON ci.CartID = c.CartID
    INNER JOIN Products p ON ci.ProductID = p.ProductID
    WHERE c.UserID = @UserID;
    
    SELECT @DeliveryPrice = Price FROM DeliveryMethods WHERE DeliveryMethodID = @DeliveryMethodID;
    
    IF @PromoCodeID IS NOT NULL
    BEGIN
        DECLARE @DiscountPercent INT;
        SELECT @DiscountPercent = DiscountPercent FROM PromoCodes WHERE PromoCodeID = @PromoCodeID;
        SET @DiscountAmount = @SubTotal * @DiscountPercent / 100.0;
    END
    
    SET @TotalAmount = @SubTotal - @DiscountAmount + @DeliveryPrice;
    
    INSERT INTO Orders (
        UserID, OrderNumber, Status, DeliveryMethodID, StoreID, AddressID, PromoCodeID,
        SubTotal, DiscountAmount, DeliveryPrice, TotalAmount,
        CustomerName, CustomerPhone, CustomerEmail, Comment
    )
    VALUES (
        @UserID, @OrderNumber, N'Ожидает оплаты', @DeliveryMethodID, @StoreID, @AddressID, @PromoCodeID,
        @SubTotal, @DiscountAmount, @DeliveryPrice, @TotalAmount,
        @CustomerName, @CustomerPhone, @CustomerEmail, @Comment
    );
    
    SET @OrderID = SCOPE_IDENTITY();
    
    INSERT INTO OrderItems (OrderID, ProductID, ProductName, Quantity, UnitPrice, TotalPrice)
    SELECT 
        @OrderID,
        p.ProductID,
        p.ProductName,
        ci.Quantity,
        p.Price,
        ci.Quantity * p.Price
    FROM CartItems ci
    INNER JOIN Carts c ON ci.CartID = c.CartID
    INNER JOIN Products p ON ci.ProductID = p.ProductID
    WHERE c.UserID = @UserID;
    
    DELETE FROM CartItems WHERE CartID IN (SELECT CartID FROM Carts WHERE UserID = @UserID);
    
    INSERT INTO OrderStatusHistory (OrderID, NewStatus, Comment)
    VALUES (@OrderID, N'Ожидает оплаты', N'Заказ создан');
END;
GO

CREATE PROCEDURE sp_GetNearbyStores
    @Latitude DECIMAL(9,6),
    @Longitude DECIMAL(9,6),
    @RadiusKm DECIMAL(5,2) = 10
AS
BEGIN
    SELECT 
        StoreID,
        StoreName,
        City,
        Street + N', ' + House AS Address,
        Phone,
        WorkingHours,
        Latitude,
        Longitude,
        (6371 * ACOS(
            COS(RADIANS(@Latitude)) * COS(RADIANS(Latitude)) * 
            COS(RADIANS(Longitude) - RADIANS(@Longitude)) + 
            SIN(RADIANS(@Latitude)) * SIN(RADIANS(Latitude))
        )) AS DistanceKm
    FROM Stores
    WHERE IsActive = 1
    HAVING (6371 * ACOS(
        COS(RADIANS(@Latitude)) * COS(RADIANS(Latitude)) * 
        COS(RADIANS(Longitude) - RADIANS(@Longitude)) + 
        SIN(RADIANS(@Latitude)) * SIN(RADIANS(Latitude))
    )) <= @RadiusKm
    ORDER BY DistanceKm;
END;
GO

CREATE PROCEDURE sp_GetProductRecommendations
    @UserID INT,
    @Count INT = 10
AS
BEGIN
    SELECT TOP (@Count)
        p.ProductID,
        p.ProductName,
        p.Price,
        p.Rating,
        c.CategoryName,
        COUNT(DISTINCT vh.ViewID) AS ViewCount
    FROM Products p
    INNER JOIN Categories c ON p.CategoryID = c.CategoryID
    LEFT JOIN ViewHistory vh ON p.ProductID = vh.ProductID
    WHERE p.IsActive = 1 
        AND p.StockQuantity > 0
        AND p.ProductID NOT IN (
            SELECT ProductID FROM OrderItems oi
            INNER JOIN Orders o ON oi.OrderID = o.OrderID
            WHERE o.UserID = @UserID
        )
    GROUP BY p.ProductID, p.ProductName, p.Price, p.Rating, c.CategoryName
    ORDER BY p.Rating DESC, ViewCount DESC;
END;
GO

-- ============================================
-- ТРИГГЕРЫ
-- ============================================

CREATE TRIGGER trg_UpdateProductRating
ON Reviews
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    DECLARE @ProductID INT;
    
    SELECT DISTINCT @ProductID = ProductID FROM inserted
    UNION
    SELECT DISTINCT ProductID FROM deleted;
    
    IF @ProductID IS NOT NULL
    BEGIN
        UPDATE Products
        SET 
            Rating = ISNULL((SELECT AVG(CAST(Rating AS DECIMAL(3,2))) FROM Reviews WHERE ProductID = @ProductID AND IsApproved = 1), 0),
            ReviewCount = (SELECT COUNT(*) FROM Reviews WHERE ProductID = @ProductID AND IsApproved = 1)
        WHERE ProductID = @ProductID;
    END
END;
GO

CREATE TRIGGER trg_OrderStatusChange
ON Orders
AFTER UPDATE
AS
BEGIN
    IF UPDATE(Status)
    BEGIN
        INSERT INTO OrderStatusHistory (OrderID, OldStatus, NewStatus, Comment)
        SELECT 
            i.OrderID,
            d.Status,
            i.Status,
            N'Статус изменён автоматически'
        FROM inserted i
        INNER JOIN deleted d ON i.OrderID = d.OrderID
        WHERE i.Status <> d.Status;
    END
END;
GO

CREATE TRIGGER trg_UpdateStockOnOrder
ON OrderItems
AFTER INSERT
AS
BEGIN
    UPDATE p
    SET p.StockQuantity = p.StockQuantity - i.Quantity
    FROM Products p
    INNER JOIN inserted i ON p.ProductID = i.ProductID;
END;
GO

CREATE TRIGGER trg_LogProductChanges
ON Products
AFTER UPDATE
AS
BEGIN
    INSERT INTO AuditLog (ActionType, EntityType, EntityID, OldValue, NewValue)
    SELECT 
        N'UPDATE',
        N'Products',
        i.ProductID,
        d.ProductName + N' | ' + CAST(d.Price AS NVARCHAR(20)),
        i.ProductName + N' | ' + CAST(i.Price AS NVARCHAR(20))
    FROM inserted i
    INNER JOIN deleted d ON i.ProductID = d.ProductID;
END;
GO

-- ============================================
-- ФУНКЦИИ
-- ============================================

CREATE FUNCTION fn_GetOrderTotal
    (@OrderID INT)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @Total DECIMAL(10,2);
    SELECT @Total = ISNULL(SUM(TotalPrice), 0) FROM OrderItems WHERE OrderID = @OrderID;
    RETURN @Total;
END;
GO

CREATE FUNCTION fn_GetUserOrderCount
    (@UserID INT)
RETURNS INT
AS
BEGIN
    DECLARE @Count INT;
    SELECT @Count = COUNT(*) FROM Orders WHERE UserID = @UserID AND Status <> N'Отменён';
    RETURN @Count;
END;
GO

CREATE FUNCTION fn_GetProductStock
    (@ProductID INT)
RETURNS INT
AS
BEGIN
    DECLARE @Stock INT;
    SELECT @Stock = ISNULL(SUM(Quantity - ReservedQuantity), 0) FROM StoreStock WHERE ProductID = @ProductID;
    RETURN @Stock;
END;
GO

-- ============================================
-- ЗАПОЛНЕНИЕ ТЕСТОВЫМИ ДАННЫМИ
-- ============================================

INSERT INTO Users (RoleID, FirstName, LastName, Email, Phone, PasswordHash, BirthDate, Gender) VALUES
(1, N'Анна', N'Петрова', N'anna@example.com', N'+79123456789', N'hash1', '2005-03-15', N'Женский'),
(2, N'Максим', N'Иванов', N'maxim@example.com', N'+79234567890', N'hash2', '1996-07-22', N'Мужской'),
(2, N'Елизавета', N'Смирнова', N'liza@example.com', N'+79345678901', N'hash3', '1990-11-10', N'Женский'),
(3, N'Дмитрий', N'Козлов', N'dmitry@example.com', N'+79456789012', N'hash4', '2002-01-05', N'Мужской'),
(2, N'София', N'Николаева', N'sofia@example.com', N'+79567890123', N'hash5', '2008-09-30', N'Женский');
GO

INSERT INTO Brands (BrandName, Country, Description) VALUES
(N'Meiji', N'Япония', N'Японский производитель сладостей'),
(N'Haribo', N'Германия', N'Немецкий производитель мармелада'),
(N'KitKat', N'Япония', N'Экзотические вкусы KitKat'),
(N'Skittles', N'США', N'Американские конфеты'),
(N'Ferrero', N'Италия', N'Итальянские шоколадные изделия');
GO

INSERT INTO Products (CategoryID, BrandID, ProductName, Slug, Description, Price, OldPrice, SKU, StockQuantity, WeightGram, CountryOfOrigin, IsExotic, IsSpicy, IsSour, IsNew) VALUES
(1, 2, N'Мармелад Харибо Кислые червячки', N'haribo-sour-worms', N'Кислый мармелад в форме червячков', 250.00, 320.00, N'MAR-001', 150, 200, N'Германия', 0, 0, 1, 0),
(1, 2, N'Мармелад Харибо Золотые медвежата', N'haribo-goldbears', N'Классический мармелад', 220.00, NULL, N'MAR-002', 200, 200, N'Германия', 0, 0, 0, 0),
(2, 5, N'Шоколад Ферреро Роше', N'ferrero-rocher', N'Шоколадные конфеты с орехами', 890.00, 990.00, N'CHO-001', 80, 300, N'Италия', 0, 0, 0, 0),
(2, 3, N'KitKat Матча', N'kitkat-matcha', N'Японский KitKat со вкусом матча', 450.00, NULL, N'CHO-002', 60, 150, N'Япония', 1, 0, 0, 1),
(3, 4, N'Скиттлс Кислые', N'skittles-sour', N'Кислые конфеты Скиттлс', 180.00, NULL, N'CAN-001', 300, 100, N'США', 0, 0, 1, 0),
(4, NULL, N'Сушеный дуриан', N'dried-durian', N'Экзотический сушеный дуриан', 1200.00, 1500.00, N'EXO-001', 25, 100, N'Таиланд', 1, 0, 0, 1),
(4, NULL, N'Сушеный манго', N'dried-mango', N'Сладкий сушеный манго', 650.00, NULL, N'EXO-002', 40, 150, N'Таиланд', 1, 0, 0, 0),
(5, NULL, N'Пирожное Моти', N'mochi-cake', N'Японское рисовое пирожное', 380.00, NULL, N'CAK-001', 50, 80, N'Япония', 1, 0, 0, 1),
(6, NULL, N'Тортик Красный бархат', N'red-velvet-cake', N'Классический красный бархат', 2500.00, NULL, N'TOR-001', 15, 1200, N'Россия', 0, 0, 0, 0),
(3, NULL, N'Конфеты с перцем чили', N'chili-candies', N'Острые конфеты с перцем чили', 350.00, NULL, N'CAN-002', 100, 100, N'Мексика', 1, 1, 0, 1);
GO

INSERT INTO Tags (TagName, ColorHex) VALUES
(N'Кислые', '#FFD700'),
(N'Острые', '#FF4500'),
(N'Экзотика', '#32CD32'),
(N'Новинка', '#1E90FF'),
(N'Хит', '#FF69B4');
GO

INSERT INTO ProductTags (ProductID, TagID) VALUES
(1, 1), (5, 1), (4, 3), (6, 3), (7, 3), (8, 3), (10, 2), (10, 3);
GO

INSERT INTO Stores (StoreName, City, Street, House, Phone, Latitude, Longitude, WorkingHours) VALUES
(N'Центральный', N'Новосибирск', N'Красный проспект', N'100', N'+7 (383) 200-00-01', 55.030000, 82.920000, N'10:00-21:00'),
(N'Северный', N'Новосибирск', N'ул. Дубровина', N'15', N'+7 (383) 200-00-02', 55.050000, 82.950000, N'10:00-20:00'),
(N'Академ', N'Новосибирск', N'пр. Академика Лаврентьева', N'6', N'+7 (383) 200-00-03', 54.850000, 83.100000, N'10:00-21:00');
GO

INSERT INTO StoreStock (StoreID, ProductID, Quantity) VALUES
(1, 1, 50), (1, 2, 40), (1, 3, 20), (1, 4, 15), (1, 5, 60),
(2, 1, 30), (2, 3, 10), (2, 5, 40), (2, 6, 5),
(3, 2, 25), (3, 4, 10), (3, 7, 15), (3, 8, 20);
GO

INSERT INTO PromoCodes (Code, DiscountPercent, MaxDiscountAmount, MinOrderAmount, UsageLimit, ValidTo, Source) VALUES
(N'SWEET15', 15, 500.00, 500.00, 1000, DATEADD(MONTH, 1, SYSDATETIME()), N'Игра'),
(N'CANDY10', 10, 300.00, 300.00, 500, DATEADD(MONTH, 1, SYSDATETIME()), N'Игра'),
(N'TRIP20', 20, 1000.00, 1000.00, 200, DATEADD(MONTH, 1, SYSDATETIME()), N'Игра'),
(N'WELCOME5', 5, 200.00, 0.00, 10000, DATEADD(YEAR, 1, SYSDATETIME()), N'Регистрация');
GO

INSERT INTO DeliveryMethods (MethodName, Description, Price, EstimatedDaysMin, EstimatedDaysMax) VALUES
(N'Самовывоз из ПВЗ', N'Забрать заказ из пункта выдачи', 0, 1, 3),
(N'Курьерская доставка', N'Доставка курьером по адресу', 300, 1, 2),
(N'Экспресс-доставка', N'Доставка в течение 2 часов', 600, 0, 1);
GO

INSERT INTO Orders (UserID, OrderNumber, Status, DeliveryMethodID, StoreID, PromoCodeID, SubTotal, DiscountAmount, DeliveryPrice, TotalAmount, CustomerName, CustomerPhone, CustomerEmail, Comment) VALUES
(2, N'CT-20250101001', N'Выполнен', 1, 1, NULL, 2500.00, 0, 0, 2500.00, N'Максим Иванов', N'+79234567890', N'maxim@example.com', NULL),
(3, N'CT-20250102002', N'Оплачен', 2, NULL, 1, 1800.00, 270.00, 300.00, 1830.00, N'Елизавета Смирнова', N'+79345678901', N'liza@example.com', N'Домофон 123'),
(4, N'CT-20250103003', N'В доставке', 2, NULL, NULL, 3600.00, 0, 300.00, 3900.00, N'Дмитрий Козлов', N'+79456789012', N'dmitry@example.com', N'Позвонить за час');
GO

INSERT INTO OrderItems (OrderID, ProductID, ProductName, Quantity, UnitPrice, TotalPrice) VALUES
(1, 1, N'Мармелад Харибо Кислые червячки', 5, 250.00, 1250.00),
(1, 3, N'Шоколад Ферреро Роше', 1, 890.00, 890.00),
(1, 5, N'Скиттлс Кислые', 2, 180.00, 360.00),
(2, 6, N'Сушеный дуриан', 1, 1200.00, 1200.00),
(2, 8, N'Пирожное Моти', 1, 380.00, 380.00),
(3, 3, N'Шоколад Ферреро Роше', 2, 890.00, 1780.00),
(3, 10, N'Конфеты с перцем чили', 1, 350.00, 350.00),
(3, 1, N'Мармелад Харибо Кислые червячки', 3, 250.00, 750.00);
GO

INSERT INTO Payments (OrderID, PaymentMethod, PaymentStatus, Amount, TransactionID) VALUES
(1, N'Банковская карта', N'Успешно', 2500.00, N'TXN-20250101001'),
(2, N'Банковская карта', N'Успешно', 1830.00, N'TXN-20250102002'),
(3, N'Банковская карта', N'Успешно', 3900.00, N'TXN-20250103003');
GO

INSERT INTO Reviews (ProductID, UserID, Rating, Comment, IsApproved) VALUES
(1, 2, 5, N'Очень вкусные и кислые! Рекомендую.', 1),
(1, 3, 4, N'Немного слишком кислые для меня, но детям нравится.', 1),
(6, 4, 3, N'Специфический вкус, но для обзора сойдёт.', 1),
(3, 2, 5, N'Лучший шоколад!', 1),
(8, 3, 5, N'Дети в восторге от моти!', 1);
GO

INSERT INTO Cart (UserID) VALUES (5);
INSERT INTO CartItems (CartID, ProductID, Quantity) VALUES
(SCOPE_IDENTITY(), 2, 2),
(SCOPE_IDENTITY(), 5, 3);
GO

INSERT INTO Wishlists (UserID, ProductID) VALUES
(2, 4), (2, 6), (3, 6), (4, 1), (5, 3);
GO

INSERT INTO SupportTickets (UserID, Subject, Message, Status, Priority) VALUES
(2, N'Проблема с оплатой', N'Не проходит оплата картой', N'Открыт', N'Высокий'),
(3, N'Вопрос по доставке', N'Можно ли изменить адрес доставки?', N'В обработке', N'Средний');
GO

INSERT INTO TicketMessages (TicketID, UserID, Message, IsFromSupport) VALUES
(1, 2, N'Не проходит оплата картой', 0),
(1, NULL, N'Здравствуйте! Попробуйте другой способ оплаты.', 1);
GO

INSERT INTO GameSessions (GameID, UserID, Score, IsWin, PromoCodeID) VALUES
(1, 5, 1200, 1, 1),
(1, 4, 800, 0, NULL),
(2, 2, 600, 1, 2),
(3, 3, 350, 1, 3),
(1, 5, 1500, 1, 1);
GO

INSERT INTO ViewHistory (UserID, ProductID) VALUES
(2, 1), (2, 3), (2, 6), (3, 6), (3, 8), (4, 1), (4, 10), (5, 3), (5, 5);
GO

INSERT INTO UserCoupons (UserID, PromoCodeID, IsUsed) VALUES
(5, 1, 0), (2, 2, 0), (3, 3, 0), (4, 4, 1);
GO

INSERT INTO Notifications (UserID, Title, Message, NotificationType) VALUES
(2, N'Заказ выполнен', N'Ваш заказ CT-20250101001 выполнен', N'Заказ'),
(3, N'Заказ оплачен', N'Ваш заказ CT-20250102002 оплачен', N'Заказ'),
(4, N'Заказ в доставке', N'Ваш заказ CT-20250103003 передан курьеру', N'Заказ'),
(5, N'Промокод получен', N'Вы получили промокод SWEET15', N'Игра');
GO

INSERT INTO NewsletterSubscriptions (Email, UserID) VALUES
(N'anna@example.com', 1),
(N'maxim@example.com', 2),
(N'liza@example.com', 3);
GO

INSERT INTO PageViews (UserID, PageURL) VALUES
(1, N'/catalog'),
(1, N'/catalog/marmalade'),
(2, N'/catalog'),
(2, N'/cart'),
(3, N'/catalog/exotic-fruits'),
(4, N'/games'),
(5, N'/games/match3');
GO

INSERT INTO ConversionEvents (UserID, EventType, EventValue) VALUES
(2, N'purchase', 2500.00),
(3, N'purchase', 1830.00),
(4, N'purchase', 3900.00),
(5, N'game_win', 1),
(2, N'game_win', 1);
GO

INSERT INTO Banners (Title, ImageURL, LinkURL, Position, SortOrder) VALUES
(N'Скидка 15% на первый заказ', N'/images/banner1.jpg', N'/catalog', N'Главная', 1),
(N'Новые экзотические фрукты', N'/images/banner2.jpg', N'/catalog/exotic-fruits', N'Главная', 2);
GO

INSERT INTO FAQ (Question, Answer, Category, SortOrder) VALUES
(N'Как получить промокод?', N'Играйте в мини-игры и выигрывайте промокоды на скидку.', N'Игры', 1),
(N'Сколько стоит доставка?', N'Самовывоз — бесплатно, курьерская доставка — от 300 рублей.', N'Доставка', 2),
(N'Можно ли вернуть товар?', N'Да, в течение 14 дней при сохранении упаковки.', N'Возврат', 3);
GO

-- ============================================
-- КОНЕЦ СКРИПТА
-- ============================================