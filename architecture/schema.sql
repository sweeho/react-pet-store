-- EXTRACTED FROM LEGACY SOURCE — evidence of what exists, not a build target. Where this disagrees with a capability delta spec, the delta spec wins.

-- User and Authentication
CREATE TABLE User (
  userName VARCHAR(25) PRIMARY KEY,
  password VARCHAR(255) NOT NULL
);

-- Customer and Profile
CREATE TABLE Profile (
  profileId INT PRIMARY KEY AUTO_INCREMENT,
  preferredLanguage VARCHAR(10) DEFAULT 'en_US',
  favoriteCategory VARCHAR(50),
  myListPreference BOOLEAN DEFAULT FALSE,
  bannerPreference BOOLEAN DEFAULT FALSE
);

CREATE TABLE Address (
  addressId INT PRIMARY KEY AUTO_INCREMENT,
  streetName1 VARCHAR(255),
  streetName2 VARCHAR(255),
  city VARCHAR(100),
  state VARCHAR(50),
  country VARCHAR(100),
  zipCode VARCHAR(20)
);

CREATE TABLE ContactInfo (
  contactInfoId INT PRIMARY KEY AUTO_INCREMENT,
  givenName VARCHAR(100),
  familyName VARCHAR(100),
  telephone VARCHAR(20),
  email VARCHAR(255),
  addressId INT,
  FOREIGN KEY (addressId) REFERENCES Address(addressId) ON DELETE CASCADE
);

CREATE TABLE CreditCard (
  creditCardId INT PRIMARY KEY AUTO_INCREMENT,
  cardNumber VARCHAR(255),
  cardType VARCHAR(50),
  expiryDate VARCHAR(10)
);

CREATE TABLE Account (
  accountId INT PRIMARY KEY AUTO_INCREMENT,
  contactInfoId INT,
  creditCardId INT,
  FOREIGN KEY (contactInfoId) REFERENCES ContactInfo(contactInfoId) ON DELETE CASCADE,
  FOREIGN KEY (creditCardId) REFERENCES CreditCard(creditCardId) ON DELETE CASCADE
);

CREATE TABLE Customer (
  customerId INT PRIMARY KEY AUTO_INCREMENT,
  userName VARCHAR(25),
  accountId INT,
  profileId INT,
  FOREIGN KEY (userName) REFERENCES User(userName),
  FOREIGN KEY (accountId) REFERENCES Account(accountId) ON DELETE CASCADE,
  FOREIGN KEY (profileId) REFERENCES Profile(profileId) ON DELETE CASCADE
);

-- Shopping Cart
CREATE TABLE ShoppingCart (
  cartId INT PRIMARY KEY AUTO_INCREMENT,
  customerId INT,
  locale VARCHAR(10) DEFAULT 'en_US',
  FOREIGN KEY (customerId) REFERENCES Customer(customerId) ON DELETE CASCADE
);

CREATE TABLE CartItem (
  cartItemId INT PRIMARY KEY AUTO_INCREMENT,
  cartId INT,
  itemId VARCHAR(50),
  quantity INT,
  FOREIGN KEY (cartId) REFERENCES ShoppingCart(cartId) ON DELETE CASCADE
);

-- Catalog
CREATE TABLE Category (
  categoryId VARCHAR(50) PRIMARY KEY,
  name VARCHAR(255)
);

CREATE TABLE Product (
  productId VARCHAR(50) PRIMARY KEY,
  name VARCHAR(255),
  categoryId VARCHAR(50),
  FOREIGN KEY (categoryId) REFERENCES Category(categoryId)
);

CREATE TABLE Catalog (
  itemId VARCHAR(50) PRIMARY KEY,
  productId VARCHAR(50),
  categoryId VARCHAR(50),
  name VARCHAR(255),
  attribute VARCHAR(255),
  unitCost FLOAT,
  FOREIGN KEY (productId) REFERENCES Product(productId),
  FOREIGN KEY (categoryId) REFERENCES Category(categoryId)
);

-- Orders
CREATE TABLE OrderStatus (
  statusId INT PRIMARY KEY AUTO_INCREMENT,
  status VARCHAR(50) UNIQUE,
  description VARCHAR(255)
);

INSERT INTO OrderStatus (status, description) VALUES
  ('PENDING', 'Order pending approval'),
  ('APPROVED', 'Order approved'),
  ('COMPLETED', 'Order completed'),
  ('DENIED', 'Order denied'),
  ('SHIPPED_PART', 'Partially shipped');

CREATE TABLE PurchaseOrder (
  orderId VARCHAR(50) PRIMARY KEY,
  userId VARCHAR(25),
  orderDate DATETIME,
  emailId VARCHAR(255),
  totalPrice FLOAT,
  billToId INT,
  shipToId INT,
  creditCardId INT,
  statusId INT,
  FOREIGN KEY (userId) REFERENCES User(userName),
  FOREIGN KEY (billToId) REFERENCES ContactInfo(contactInfoId),
  FOREIGN KEY (shipToId) REFERENCES ContactInfo(contactInfoId),
  FOREIGN KEY (creditCardId) REFERENCES CreditCard(creditCardId),
  FOREIGN KEY (statusId) REFERENCES OrderStatus(statusId)
);

CREATE TABLE LineItem (
  lineItemId INT PRIMARY KEY AUTO_INCREMENT,
  orderId VARCHAR(50),
  itemId VARCHAR(50),
  quantity INT,
  quantityShipped INT DEFAULT 0,
  unitPrice FLOAT,
  categoryId VARCHAR(50),
  productId VARCHAR(50),
  lineNumber INT,
  FOREIGN KEY (orderId) REFERENCES PurchaseOrder(orderId) ON DELETE CASCADE,
  FOREIGN KEY (itemId) REFERENCES Catalog(itemId)
);

-- Supplier Management
CREATE TABLE Inventory (
  itemId VARCHAR(50) PRIMARY KEY,
  quantity INT
);

CREATE TABLE SupplierOrder (
  poId VARCHAR(50) PRIMARY KEY,
  poDate BIGINT,
  poStatus VARCHAR(50),
  contactInfoId INT,
  FOREIGN KEY (contactInfoId) REFERENCES ContactInfo(contactInfoId) ON DELETE CASCADE,
  FOREIGN KEY (poStatus) REFERENCES OrderStatus(status)
);

CREATE TABLE SupplierLineItem (
  lineItemId INT PRIMARY KEY AUTO_INCREMENT,
  poId VARCHAR(50),
  itemId VARCHAR(50),
  quantity INT,
  quantityShipped INT DEFAULT 0,
  unitPrice FLOAT,
  categoryId VARCHAR(50),
  productId VARCHAR(50),
  lineNumber INT,
  FOREIGN KEY (poId) REFERENCES SupplierOrder(poId) ON DELETE CASCADE,
  FOREIGN KEY (itemId) REFERENCES Inventory(itemId)
);

-- Indexes for performance
CREATE INDEX idx_user_profile ON Customer(profileId);
CREATE INDEX idx_user_account ON Customer(accountId);
CREATE INDEX idx_customer_cart ON ShoppingCart(customerId);
CREATE INDEX idx_cart_items ON CartItem(cartId);
CREATE INDEX idx_order_user ON PurchaseOrder(userId);
CREATE INDEX idx_order_status ON PurchaseOrder(statusId);
CREATE INDEX idx_lineitem_order ON LineItem(orderId);
CREATE INDEX idx_supplier_order_status ON SupplierOrder(poStatus);
CREATE INDEX idx_supplier_lineitem ON SupplierLineItem(poId);
CREATE INDEX idx_inventory_quantity ON Inventory(quantity);
