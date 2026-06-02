-- =============================================================================
-- M5: Data Population & Validation Queries
-- Database: event_management_db
-- Description: Full DML script — INSERT, UPDATE, DELETE, and validation
-- =============================================================================

SET FOREIGN_KEY_CHECKS = 0;
SET SQL_MODE = 'NO_AUTO_VALUE_ON_ZERO';

-- =============================================================================
-- DROP & RECREATE DATABASE
-- =============================================================================
DROP DATABASE IF EXISTS event_management_db;
CREATE DATABASE event_management_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;
USE event_management_db;

-- =============================================================================
-- TABLE DEFINITIONS
-- =============================================================================

CREATE TABLE Categories (
    category_id   INT            NOT NULL AUTO_INCREMENT,
    category_name VARCHAR(100)   NOT NULL,
    description   TEXT,
    created_at    DATE,
    PRIMARY KEY (category_id)
);

CREATE TABLE Organizers (
    organizer_id   INT          NOT NULL AUTO_INCREMENT,
    organizer_name VARCHAR(150) NOT NULL,
    email          VARCHAR(150) NOT NULL UNIQUE,
    phone          VARCHAR(50),
    organization   VARCHAR(200),
    created_at     DATE,
    PRIMARY KEY (organizer_id)
);

CREATE TABLE Users (
    user_id    INT          NOT NULL AUTO_INCREMENT,
    name       VARCHAR(150) NOT NULL,
    email      VARCHAR(150) NOT NULL UNIQUE,
    password   VARCHAR(255) NOT NULL,
    role       ENUM('admin','user','customer') NOT NULL DEFAULT 'user',
    phone      VARCHAR(50),
    created_at DATE,
    PRIMARY KEY (user_id)
);

CREATE TABLE Events (
    event_id        INT          NOT NULL AUTO_INCREMENT,
    category_id     INT          NOT NULL,
    organizer_id    INT          NOT NULL,
    event_name      VARCHAR(200) NOT NULL,
    event_date      DATE         NOT NULL,
    event_time      TIME,
    venue           VARCHAR(200),
    total_seats     INT          NOT NULL DEFAULT 0,
    available_seats INT          NOT NULL DEFAULT 0,
    status          ENUM('upcoming','completed','cancelled') NOT NULL DEFAULT 'upcoming',
    description     TEXT,
    created_at      DATE,
    PRIMARY KEY (event_id),
    CONSTRAINT fk_event_category  FOREIGN KEY (category_id)  REFERENCES Categories (category_id),
    CONSTRAINT fk_event_organizer FOREIGN KEY (organizer_id) REFERENCES Organizers (organizer_id)
);

CREATE TABLE Bookings (
    booking_id     INT          NOT NULL AUTO_INCREMENT,
    user_id        INT          NOT NULL,
    event_id       INT          NOT NULL,
    seats_booked   INT          NOT NULL DEFAULT 1,
    booking_status ENUM('pending','confirmed','cancelled') NOT NULL DEFAULT 'pending',
    booking_date   DATE,
    notes          TEXT,
    PRIMARY KEY (booking_id),
    CONSTRAINT fk_booking_user  FOREIGN KEY (user_id)  REFERENCES Users  (user_id),
    CONSTRAINT fk_booking_event FOREIGN KEY (event_id) REFERENCES Events (event_id)
);

CREATE TABLE Feedback (
    feedback_id  INT NOT NULL AUTO_INCREMENT,
    user_id      INT NOT NULL,
    event_id     INT NOT NULL,
    rating       TINYINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment      TEXT,
    submitted_at DATE,
    PRIMARY KEY (feedback_id),
    CONSTRAINT fk_feedback_user  FOREIGN KEY (user_id)  REFERENCES Users  (user_id),
    CONSTRAINT fk_feedback_event FOREIGN KEY (event_id) REFERENCES Events (event_id)
);


-- =============================================================================
-- INSERT: Categories (20 rows)
-- =============================================================================
INSERT INTO Categories (category_id, category_name, description, created_at) VALUES
  (1, 'Health', 'Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.', '4/28/2026'),
  (2, 'Business', 'In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.', '10/10/2025'),
  (3, 'Music', 'Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.', '4/6/2026'),
  (4, 'Technology', 'Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.', '8/29/2025'),
  (5, 'Technology', 'Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.', '4/11/2026'),
  (6, 'Gaming', 'Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.\n\nCum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.\n\nEtiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.', '4/12/2026'),
  (7, 'Fashion', 'Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.', '5/23/2025'),
  (8, 'Food', 'Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.', '11/19/2025'),
  (9, 'Music', 'Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.', '4/5/2026'),
  (10, 'Technology', 'Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit.', '3/28/2026'),
  (11, 'Education', 'Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.\n\nVestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.', '9/6/2025'),
  (12, 'Art', 'Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.', '3/20/2026'),
  (13, 'Health', 'Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero.', '9/21/2025'),
  (14, 'Sports', 'Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris.\n\nMorbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.\n\nFusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.', '6/27/2025'),
  (15, 'Business', 'Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.\n\nSed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.\n\nPellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.', '1/29/2026'),
  (16, 'Sports', 'Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.', '7/10/2025'),
  (17, 'Sports', 'Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris.', '5/28/2025'),
  (18, 'Music', 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin risus. Praesent lectus.\n\nVestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis.\n\nDuis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.', '7/25/2025'),
  (19, 'Health', 'Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.', '12/10/2025'),
  (20, 'Gaming', 'In congue. Etiam justo. Etiam pretium iaculis justo.\n\nIn hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.\n\nNulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.', '3/22/2026');

-- =============================================================================
-- INSERT: Organizers (50 rows)
-- =============================================================================
INSERT INTO Organizers (organizer_id, organizer_name, email, phone, organization, created_at) VALUES
  (1, 'Ignace Adamovich', 'iadamovich0@tumblr.com', '+351 (629) 402-3869', 'Steuber LLC', '8/23/2025'),
  (2, 'Peta Joly', 'pjoly1@sciencedaily.com', '+51 (608) 203-2923', 'Marvin, Wilkinson and Lockman', '4/3/2026'),
  (3, 'Desiri Brownlea', 'dbrownlea2@sitemeter.com', '+92 (795) 374-8154', 'Mohr LLC', '11/19/2025'),
  (4, 'Iorgo Binner', 'ibinner3@discuz.net', '+86 (986) 656-8446', 'Herzog, Streich and Oberbrunner', '10/31/2025'),
  (5, 'Zorah Pendrigh', 'zpendrigh4@baidu.com', '+1 (390) 866-1450', 'Kovacek Inc', '9/22/2025'),
  (6, 'Joaquin Bickersteth', 'jbickersteth5@behance.net', '+57 (466) 924-0807', 'Strosin-Moen', '1/22/2026'),
  (7, 'Pansy Philpots', 'pphilpots6@bing.com', '+93 (636) 210-9455', 'Waelchi, Farrell and Becker', '10/31/2025'),
  (8, 'Milty Domeny', 'mdomeny7@cyberchimps.com', '+380 (761) 717-9271', 'Kozey-Anderson', '10/12/2025'),
  (9, 'Charis Rydings', 'crydings8@reference.com', '+1 (337) 302-7403', 'Cummings-Yost', '7/11/2025'),
  (10, 'Della Maciaszczyk', 'dmaciaszczyk9@virginia.edu', '+33 (969) 941-9205', 'Bartoletti-Carroll', '3/30/2026'),
  (11, 'Jemimah Cree', 'jcreea@springer.com', '+590 (532) 366-3240', 'Ankunding, Steuber and Wolff', '8/20/2025'),
  (12, 'Evanne Jonke', 'ejonkeb@virginia.edu', '+62 (410) 277-7750', 'Mueller-Barton', '8/28/2025'),
  (13, 'Tuesday Drohun', 'tdrohunc@tinypic.com', '+509 (103) 475-5665', 'Willms, Considine and Weimann', '9/17/2025'),
  (14, 'Andre Braysher', 'abraysherd@japanpost.jp', '+351 (670) 439-8951', 'Hamill-Yost', '11/4/2025'),
  (15, 'Wendy Curds', 'wcurdse@friendfeed.com', '+86 (997) 635-0565', 'Stanton-Hirthe', '4/11/2026'),
  (16, 'Lil Cranston', 'lcranstonf@deviantart.com', '+236 (381) 241-1865', 'Jast-Heidenreich', '10/10/2025'),
  (17, 'Perry Ladewig', 'pladewigg@imageshack.us', '+216 (792) 503-6318', 'Hoeger, Hayes and Conroy', '1/10/2026'),
  (18, 'Cammie Infantino', 'cinfantinoh@artisteer.com', '+86 (393) 221-8608', 'Murazik-Hintz', '9/29/2025'),
  (19, 'Stoddard Croasdale', 'scroasdalei@posterous.com', '+502 (926) 932-9500', 'Herman-Jacobson', '6/3/2025'),
  (20, 'Aarika O\'Loghlen', 'aologhlenj@wikipedia.org', '+62 (560) 598-1623', 'Bayer-Emard', '9/29/2025'),
  (21, 'Heindrick Trimby', 'htrimbyk@theguardian.com', '+62 (774) 785-8849', 'Hauck LLC', '3/1/2026'),
  (22, 'Rena Rivalland', 'rrivallandl@reverbnation.com', '+54 (241) 360-5718', 'Will, Hoeger and Murray', '4/24/2026'),
  (23, 'Amandy Chaffen', 'achaffenm@businessinsider.com', '+267 (914) 885-1482', 'Langworth Group', '1/24/2026'),
  (24, 'Bettina Rawne', 'brawnen@barnesandnoble.com', '+86 (854) 943-8680', 'Feest-Yundt', '3/6/2026'),
  (25, 'Amanda Luby', 'alubyo@dailymail.co.uk', '+355 (607) 783-1939', 'Becker-Schmitt', '6/26/2025'),
  (26, 'Greggory Mansbridge', 'gmansbridgep@opensource.org', '+55 (912) 549-3705', 'Bednar LLC', '7/20/2025'),
  (27, 'Dulcy Pietesch', 'dpieteschq@livejournal.com', '+46 (216) 687-5444', 'Beahan-Rosenbaum', '2/10/2026'),
  (28, 'Minda Petracci', 'mpetraccir@prweb.com', '+995 (815) 873-3414', 'Kuhic and Sons', '3/24/2026'),
  (29, 'Nancy Dubbin', 'ndubbins@google.com.au', '+55 (880) 334-2993', 'Heller, Schroeder and Durgan', '3/1/2026'),
  (30, 'Haslett Kendall', 'hkendallt@google.pl', '+48 (553) 205-0346', 'Farrell-Wisozk', '6/12/2025'),
  (31, 'Florinda Rylatt', 'frylattu@irs.gov', '+33 (159) 309-3303', 'Haag Inc', '7/28/2025'),
  (32, 'Carina Folley', 'cfolleyv@discovery.com', '+966 (515) 129-9002', 'Abshire-Turcotte', '3/31/2026'),
  (33, 'Horton Ogles', 'hoglesw@istockphoto.com', '+86 (664) 308-2225', 'Hoeger LLC', '8/16/2025'),
  (34, 'Frederique Bunney', 'fbunneyx@51.la', '+48 (124) 285-5998', 'Goyette and Sons', '9/27/2025'),
  (35, 'Robinette Verma', 'rvermay@behance.net', '+33 (347) 927-7079', 'Borer, Swift and Smitham', '12/8/2025'),
  (36, 'Sharron Soutter', 'ssoutterz@discovery.com', '+7 (964) 888-0275', 'D\'Amore Inc', '8/11/2025'),
  (37, 'Benita Skerrett', 'bskerrett10@weebly.com', '+84 (866) 393-8788', 'Crist, Cruickshank and Ullrich', '2/14/2026'),
  (38, 'Donny Baggott', 'dbaggott11@woothemes.com', '+30 (581) 348-4490', 'Torp, Runolfsdottir and Yost', '9/19/2025'),
  (39, 'Tallulah Janew', 'tjanew12@linkedin.com', '+386 (449) 553-7721', 'Blick LLC', '4/22/2026'),
  (40, 'Emili Nizet', 'enizet13@microsoft.com', '+46 (457) 664-0872', 'Lesch Group', '3/3/2026'),
  (41, 'Janice Mollison', 'jmollison14@techcrunch.com', '+261 (742) 709-7905', 'Hintz-Zieme', '9/18/2025'),
  (42, 'Vasili Farrans', 'vfarrans15@bloomberg.com', '+86 (502) 310-3152', 'Vandervort and Sons', '12/9/2025'),
  (43, 'Mellisent Sidebottom', 'msidebottom16@yahoo.com', '+385 (613) 391-8240', 'Terry-Von', '11/20/2025'),
  (44, 'Nealy Wintour', 'nwintour17@go.com', '+86 (185) 180-0589', 'Wisoky-Bins', '4/8/2026'),
  (45, 'Siana Simms', 'ssimms18@fotki.com', '+502 (853) 630-4380', 'Farrell Inc', '9/27/2025'),
  (46, 'Hannah Costello', 'hcostello19@histats.com', '+62 (887) 759-5344', 'Reinger-Dicki', '5/8/2026'),
  (47, 'Demetra Horche', 'dhorche1a@parallels.com', '+63 (466) 810-9313', 'Jerde Group', '9/7/2025'),
  (48, 'Emmalee Gabey', 'egabey1b@comcast.net', '+254 (328) 256-1733', 'Hand, Hilpert and Bogan', '6/5/2025'),
  (49, 'Jordan Glencross', 'jglencross1c@dedecms.com', '+234 (762) 628-2180', 'Adams-Oberbrunner', '3/31/2026'),
  (50, 'Dehlia Keesman', 'dkeesman1d@linkedin.com', '+63 (108) 170-7536', 'Kuhlman, Walter and Bauch', '4/5/2026');

-- =============================================================================
-- INSERT: Users (100 rows)
-- =============================================================================
INSERT INTO Users (user_id, name, email, password, role, phone, created_at) VALUES
  (1, 'Emmy Dran', 'edran0@odnoklassniki.ru', 'mL3(KouLEg', 'admin', '+55 (375) 874-6490', '4/23/2026'),
  (2, 'Christoper Tindall', 'ctindall1@pinterest.com', 'iO0\'\'ep%77', 'user', '+255 (347) 367-6645', '12/8/2025'),
  (3, 'Rocky Mertsching', 'rmertsching2@woothemes.com', 'rU3!l4Qd\'NJxt', 'admin', '+370 (230) 224-7278', '6/11/2025'),
  (4, 'Teddie Hattam', 'thattam3@cbslocal.com', 'pQ6\'HdReYRwx3J+M', 'user', '+7 (450) 676-8974', '3/19/2026'),
  (5, 'Dael Harbard', 'dharbard4@census.gov', 'zQ0_Y\'bHYz', 'user', '+62 (735) 648-2243', '4/24/2026'),
  (6, 'Lenee Bestwick', 'lbestwick5@geocities.com', 'uV5.j$bw?E_', 'admin', '+86 (590) 940-3872', '8/12/2025'),
  (7, 'Grayce Dallosso', 'gdallosso6@ted.com', 'tH9?,F.!h@jL.G', 'admin', '+62 (697) 358-6028', '8/10/2025'),
  (8, 'Barclay Gillion', 'bgillion7@meetup.com', 'vN0}"{NurQU<', 'user', '+86 (665) 230-6945', '11/2/2025'),
  (9, 'Petra Freear', 'pfreear8@amazon.co.jp', 'hV3|#iS`Md`f', 'admin', '+86 (405) 414-8208', '11/16/2025'),
  (10, 'Giuditta Spraberry', 'gspraberry9@aol.com', 'aU6,a&Lh\'v}o1}', 'admin', '+52 (891) 902-3853', '6/26/2025'),
  (11, 'Angie Farahar', 'afarahara@umich.edu', 'uS9>&9~kH2$ZD', 'customer', '+62 (156) 567-5408', '7/2/2025'),
  (12, 'Imojean Lasseter', 'ilasseterb@virginia.edu', 'mP8%tA_*2', 'user', '+374 (593) 184-2815', '1/25/2026'),
  (13, 'Gerrie Garrit', 'ggarritc@aboutads.info', 'mT6"cvy/(', 'user', '+7 (756) 159-0888', '6/21/2025'),
  (14, 'Towny McKelloch', 'tmckellochd@hexun.com', 'yE4~HYkMydhCjm', 'customer', '+353 (567) 178-1531', '1/26/2026'),
  (15, 'Bartie Sieghard', 'bsiegharde@sun.com', 'cY7/{$,dW', 'user', '+51 (381) 499-0308', '4/15/2026'),
  (16, 'Petronilla Konert', 'pkonertf@wisc.edu', 'jS3"OxvE+Q', 'admin', '+92 (382) 526-3721', '5/26/2025'),
  (17, 'Alaric Fairall', 'afairallg@free.fr', 'gJ9`}VXHw"mZFV', 'user', '+358 (406) 174-5328', '9/9/2025'),
  (18, 'Dov Hofton', 'dhoftonh@google.com.hk', 'gL0.L18k{K6sqk', 'customer', '+86 (783) 736-5573', '2/14/2026'),
  (19, 'Brand Leavry', 'bleavryi@parallels.com', 'gV0<mN=N', 'admin', '+33 (376) 953-1378', '6/23/2025'),
  (20, 'Wendi Ramey', 'wrameyj@google.ca', 'yB4=gkNJ5nBI,FI%', 'customer', '+48 (933) 494-6403', '11/29/2025'),
  (21, 'Juana Izac', 'jizack@blog.com', 'lY0{RV"(mjq=', 'customer', '+46 (644) 620-4571', '4/13/2026'),
  (22, 'Lorene Grunbaum', 'lgrunbauml@si.edu', 'mF4&0@wKrm<Bz(', 'admin', '+57 (299) 445-2730', '7/24/2025'),
  (23, 'Maryellen Triggle', 'mtrigglem@noaa.gov', 'pA7\\jax7C', 'user', '+63 (311) 229-9092', '2/22/2026'),
  (24, 'Mikey Frances', 'mfrancesn@cpanel.net', 'sR8|5kG.&g|+', 'admin', '+57 (451) 487-1625', '2/22/2026'),
  (25, 'Celene Arundale', 'carundaleo@umich.edu', 'sO2.KhM?}"b2!(\'', 'user', '+976 (816) 143-9794', '12/6/2025'),
  (26, 'Antoine Brinkman', 'abrinkmanp@sphinn.com', 'fC7$VJ_u', 'admin', '+965 (428) 979-9455', '8/23/2025'),
  (27, 'Karylin Rabjohns', 'krabjohnsq@loc.gov', 'cK6%Uo(CeC"4*e', 'admin', '+351 (429) 604-5975', '2/19/2026'),
  (28, 'Netti Buckoke', 'nbuckoker@hostgator.com', 'qQ9<ZHv<a', 'admin', '+86 (298) 674-5353', '5/29/2025'),
  (29, 'Reta Dorie', 'rdories@lycos.com', 'zX3_U=J(I3', 'admin', '+54 (539) 287-0233', '10/30/2025'),
  (30, 'Herve Wile', 'hwilet@adobe.com', 'kE2~Q\'L\\1W', 'user', '+86 (982) 462-5725', '5/14/2026'),
  (31, 'Dave Reiach', 'dreiachu@reddit.com', 'mE5`\\g6#}*=Py3L', 'admin', '+62 (731) 994-2174', '10/20/2025'),
  (32, 'Boot Hackney', 'bhackneyv@virginia.edu', 'aL8\'RM5rF=Dk)KB', 'admin', '+62 (413) 383-8880', '8/4/2025'),
  (33, 'Sibyl Morrowe', 'smorrowew@qq.com', 'xG4}i!Eh', 'user', '+994 (556) 985-4030', '7/30/2025'),
  (34, 'Sandor Fendt', 'sfendtx@eepurl.com', 'sV7!\\WTU@', 'user', '+7 (794) 776-3279', '4/7/2026'),
  (35, 'Vinny Paolacci', 'vpaolacciy@nifty.com', 'zT9=C@?JG', 'customer', '+7 (831) 920-6873', '5/17/2025'),
  (36, 'Karissa Churchyard', 'kchurchyardz@disqus.com', 'eV6\'PuNIy7Dh', 'admin', '+86 (622) 917-2075', '12/12/2025'),
  (37, 'Corney Kubec', 'ckubec10@ucoz.com', 'eE7*0a@J.0PE2T', 'admin', '+58 (335) 925-0894', '2/4/2026'),
  (38, 'Kelly Coughlin', 'kcoughlin11@google.ru', 'bG7?pZ/\'!jSZp0)', 'customer', '+86 (277) 838-3264', '5/26/2025'),
  (39, 'Belva L\'argent', 'blargent12@360.cn', 'zA9$P7cU4', 'customer', '+263 (712) 966-4908', '11/5/2025'),
  (40, 'Danita Gueste', 'dgueste13@ucoz.ru', 'qS9#9DZs19KA?', 'admin', '+352 (525) 658-6382', '11/18/2025'),
  (41, 'Naomi Lathleiffure', 'nlathleiffure14@simplemachines.org', 'fT8/o$_m%8H*<tk', 'user', '+62 (754) 311-2170', '11/8/2025'),
  (42, 'Bettye Glaves', 'bglaves15@seattletimes.com', 'mY3$O~i$zw=(7w', 'customer', '+972 (293) 980-6280', '1/23/2026'),
  (43, 'Loella Wolstenholme', 'lwolstenholme16@xrea.com', 'hI4!+7fLI?jH<}O', 'user', '+62 (465) 477-7994', '9/3/2025'),
  (44, 'Pippy Champniss', 'pchampniss17@wsj.com', 'tA1|9T/WH{u&L@j', 'admin', '+63 (213) 632-1313', '11/13/2025'),
  (45, 'Rustie Drezzer', 'rdrezzer18@msn.com', 'mD9*dOH7>FZaji+', 'customer', '+373 (456) 902-5220', '3/12/2026'),
  (46, 'Tedra Burridge', 'tburridge19@wp.com', 'uA7&4yo<b?pI', 'customer', '+420 (559) 843-6180', '10/24/2025'),
  (47, 'Alexis Fitch', 'afitch1a@dmoz.org', 'rS6<o#E*`n', 'user', '+52 (781) 609-7969', '4/1/2026'),
  (48, 'Rouvin Awcoate', 'rawcoate1b@mlb.com', 'mN4?|2vqAH', 'customer', '+57 (958) 910-1289', '4/2/2026'),
  (49, 'Cristal MacPeake', 'cmacpeake1c@fda.gov', 'qB1&<9u{5!4pi', 'customer', '+7 (336) 619-1423', '4/17/2026'),
  (50, 'Smitty Rylance', 'srylance1d@latimes.com', 'yS4~p>OGncEah`V5', 'admin', '+963 (230) 447-3046', '5/9/2026'),
  (51, 'Morgana Kosel', 'mkosel1e@uiuc.edu', 'zL0)!=H%G', 'admin', '+81 (922) 653-9243', '1/21/2026'),
  (52, 'Mikey Cullinan', 'mcullinan1f@japanpost.jp', 'gY2|c\\XLi', 'user', '+66 (298) 389-6018', '8/7/2025'),
  (53, 'Hazlett Calcut', 'hcalcut1g@ning.com', 'uP8#d)H++i5%*', 'user', '+56 (826) 955-3371', '2/1/2026'),
  (54, 'Dory Paulillo', 'dpaulillo1h@creativecommons.org', 'oK6|g.8s1L@%+8,', 'customer', '+86 (367) 806-5048', '8/7/2025'),
  (55, 'Dorelle Gimblet', 'dgimblet1i@businessweek.com', 'jD8/|@`v`!vVG', 'customer', '+86 (688) 291-8416', '1/23/2026'),
  (56, 'Alford Kearton', 'akearton1j@ycombinator.com', 'uM4@E@D6@>fKI', 'customer', '+61 (466) 860-9932', '12/2/2025'),
  (57, 'Maury Youthed', 'myouthed1k@yolasite.com', 'tZ8<ag#82VPA', 'user', '+62 (951) 330-1694', '4/18/2026'),
  (58, 'Drugi Danilenko', 'ddanilenko1l@patch.com', 'zM6`2|vMQ}T9t_)', 'user', '+54 (419) 306-2195', '4/2/2026'),
  (59, 'Tory Beddon', 'tbeddon1m@spiegel.de', 'nD0~vuEG0)', 'customer', '+62 (912) 876-4102', '7/21/2025'),
  (60, 'Christine Grice', 'cgrice1n@hatena.ne.jp', 'hP8=!&*PXand', 'customer', '+86 (755) 164-3592', '8/14/2025'),
  (61, 'Gussi Forsyde', 'gforsyde1o@wikia.com', 'uA5.S11=W', 'user', '+86 (505) 906-8785', '4/16/2026'),
  (62, 'Tamma Clemes', 'tclemes1p@icq.com', 'lX7<ZCo"i@i', 'admin', '+590 (718) 764-2977', '5/9/2026'),
  (63, 'Neila Anlay', 'nanlay1q@abc.net.au', 'yH7\'f0`K`29t', 'user', '+62 (133) 420-2826', '4/1/2026'),
  (64, 'Janeta Constant', 'jconstant1r@cpanel.net', 'zW9!3pk<%)+zTn', 'admin', '+62 (863) 178-2738', '5/25/2025'),
  (65, 'Sherwood Knox', 'sknox1s@ucla.edu', 'kF4#{5.!Uq6w', 'customer', '+62 (211) 686-0046', '8/5/2025'),
  (66, 'Aldo Edgson', 'aedgson1t@reference.com', 'pM8%UHPi`', 'admin', '+260 (282) 819-3114', '7/22/2025'),
  (67, 'Beatrice Duthie', 'bduthie1u@weather.com', 'yV8&g@|S6SW$', 'admin', '+994 (913) 566-2626', '1/16/2026'),
  (68, 'Vale Champe', 'vchampe1v@fotki.com', 'rQ3/x{h+r', 'customer', '+86 (160) 520-3396', '1/31/2026'),
  (69, 'Miguel Reynish', 'mreynish1w@posterous.com', 'pE6&>&5<A}nx', 'admin', '+256 (678) 180-1935', '4/9/2026'),
  (70, 'Helga Bull', 'hbull1x@people.com.cn', 'sE0=<B40qX,DSy', 'user', '+86 (761) 308-4019', '3/25/2026'),
  (71, 'Crichton Dilliston', 'cdilliston1y@bbc.co.uk', 'eJ8<3!_O"dopX1', 'admin', '+964 (216) 592-9919', '8/2/2025'),
  (72, 'Kassi De La Haye', 'kde1z@senate.gov', 'iZ9(kP$@\\i=51*S', 'admin', '+63 (346) 994-8742', '5/27/2025'),
  (73, 'Bartholemy Erett', 'berett20@tinyurl.com', 'mP4/CvJofoQ', 'customer', '+63 (964) 368-6982', '3/9/2026'),
  (74, 'Christy Gniewosz', 'cgniewosz21@discuz.net', 'nG4`aY.&,"<', 'user', '+62 (519) 183-7548', '11/29/2025'),
  (75, 'Hilarius Highwood', 'hhighwood22@dion.ne.jp', 'dK6`>05q1r97N\'', 'user', '+62 (616) 919-1018', '6/13/2025'),
  (76, 'Roderic Swale', 'rswale23@state.gov', 'zK8@ns>}w>)', 'customer', '+54 (487) 782-7950', '4/5/2026'),
  (77, 'Dory Gregoletti', 'dgregoletti24@usa.gov', 'oJ7"T+CXb', 'admin', '+48 (614) 841-7596', '2/22/2026'),
  (78, 'Zonda Petranek', 'zpetranek25@tinyurl.com', 'gM4#Jhf"w&H', 'admin', '+86 (332) 597-6079', '12/17/2025'),
  (79, 'Judye Iashvili', 'jiashvili26@dedecms.com', 'oR7&M$W=7m.', 'customer', '+7 (807) 121-4879', '5/7/2026'),
  (80, 'Falito Boundey', 'fboundey27@jalbum.net', 'fD8+<LiA', 'customer', '+358 (819) 261-5881', '10/24/2025'),
  (81, 'Berkly Dollin', 'bdollin28@state.tx.us', 'sN1{I1X#$12', 'customer', '+86 (898) 899-5794', '5/26/2025'),
  (82, 'Meredith Buscher', 'mbuscher29@house.gov', 'zW9#Z._Xi$', 'user', '+225 (570) 586-7918', '3/2/2026'),
  (83, 'Lorenzo Yankishin', 'lyankishin2a@washingtonpost.com', 'fO1/`B6t*rcO(/', 'customer', '+60 (447) 839-6984', '7/24/2025'),
  (84, 'Micky Lockwood', 'mlockwood2b@ft.com', 'dR1{GhF&', 'user', '+86 (398) 106-6258', '2/22/2026'),
  (85, 'Chester Nannini', 'cnannini2c@cdbaby.com', 'pL5@{=/N.d"Y_b', 'user', '+55 (139) 548-7645', '10/1/2025'),
  (86, 'Kaleb Orridge', 'korridge2d@un.org', 'kO6_<,<HP', 'user', '+7 (798) 576-1566', '9/29/2025'),
  (87, 'Bengt Mazdon', 'bmazdon2e@ucsd.edu', 'gI5"hnIcD', 'admin', '+33 (327) 558-6377', '1/1/2026'),
  (88, 'Eustacia Michurin', 'emichurin2f@privacy.gov.au', 'jI7=6Ty$kpw4,eu', 'admin', '+62 (273) 808-9644', '5/27/2025'),
  (89, 'Elsi Lantuffe', 'elantuffe2g@plala.or.jp', 'zD8&4)Lj#', 'admin', '+55 (219) 620-7696', '7/8/2025'),
  (90, 'Thomasa Uccelli', 'tuccelli2h@wp.com', 'dQ4#k4CIg15vBB\\R', 'admin', '+86 (675) 323-0488', '2/13/2026'),
  (91, 'Mignon Drewry', 'mdrewry2i@ustream.tv', 'uT0!H}Q"', 'user', '+261 (952) 673-7088', '6/14/2025'),
  (92, 'Hebert McClory', 'hmcclory2j@dropbox.com', 'oU7/u5\'hqFHnOWU', 'admin', '+86 (210) 820-4025', '2/26/2026'),
  (93, 'Davidson Forman', 'dforman2k@hubpages.com', 'eL2>rL+PZdg7e', 'admin', '+86 (512) 408-7577', '2/6/2026'),
  (94, 'Bertram Orrett', 'borrett2l@example.com', 'mC3/K9!|GW_P\'<x', 'user', '+36 (648) 697-6970', '12/4/2025'),
  (95, 'Inness Rudman', 'irudman2m@umich.edu', 'sI9|k(F\\tdjk', 'user', '+54 (804) 621-2041', '10/20/2025'),
  (96, 'Erma Yakovl', 'eyakovl2n@merriam-webster.com', 'dD2@C#4/u|', 'customer', '+48 (948) 431-3529', '5/28/2025'),
  (97, 'Lockwood Yakobovicz', 'lyakobovicz2o@php.net', 'fI4<ssNt`mC\'n7n', 'user', '+63 (995) 401-1091', '12/29/2025'),
  (98, 'Nikola Matuskiewicz', 'nmatuskiewicz2p@nsw.gov.au', 'oF1<DH{72\'', 'user', '+62 (752) 911-4126', '5/28/2025'),
  (99, 'Susanne Flobert', 'sflobert2q@yahoo.co.jp', 'hV2=yJ8Zn', 'admin', '+237 (641) 705-2585', '4/7/2026'),
  (100, 'Paula Thandi', 'pthandi2r@pbs.org', 'gI4#2Xghb"', 'user', '+420 (273) 490-9090', '5/1/2026');

-- =============================================================================
-- INSERT: Events (100 rows)
-- =============================================================================
INSERT INTO Events (event_id, category_id, organizer_id, event_name, event_date, event_time, venue, total_seats, available_seats, status, description, created_at) VALUES
  (1, 16, 40, 'Tech Conference', '2/3/2026', '11:11 PM', 'El Cantón de San Pablo', 485, 93, 'completed', 'Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.', '2/9/2026'),
  (2, 6, 23, 'Startup Meetup', '5/10/2026', '10:23 PM', 'Seseng', 76, 365, 'completed', 'Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.\n\nPraesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.', '8/9/2025'),
  (3, 2, 19, 'Health Seminar', '4/3/2026', '11:22 AM', 'Zengtian', 468, 274, 'upcoming', 'Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero.', '12/28/2025'),
  (4, 4, 30, 'Gaming Expo', '8/7/2025', '3:22 AM', 'Shiniujiang', 449, 67, 'cancelled', 'Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.', '8/8/2025'),
  (5, 17, 7, 'Food Carnival', '3/18/2026', '4:04 PM', 'Wenquan', 401, 353, 'cancelled', 'Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.', '6/28/2025'),
  (6, 20, 3, 'Health Seminar', '5/30/2025', '7:38 AM', 'Carolina', 388, 310, 'upcoming', 'Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.\n\nVestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.', '10/21/2025'),
  (7, 6, 24, 'Food Carnival', '7/28/2025', '10:48 AM', 'La Banda', 437, 465, 'cancelled', 'Fusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.', '7/23/2025'),
  (8, 20, 48, 'Tech Conference', '1/8/2026', '6:54 PM', 'Ulety', 446, 106, 'cancelled', 'Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.\n\nIn quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.', '2/25/2026'),
  (9, 3, 39, 'Health Seminar', '10/19/2025', '7:13 PM', 'Concepción', 492, 139, 'cancelled', 'Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.\n\nQuisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.\n\nVestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.', '1/15/2026'),
  (10, 19, 2, 'AI Workshop', '7/6/2025', '2:24 AM', 'Laocheng', 106, 239, 'upcoming', 'Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.\n\nQuisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.\n\nPhasellus in felis. Donec semper sapien a libero. Nam dui.', '12/25/2025'),
  (11, 6, 29, 'Health Seminar', '4/13/2026', '6:35 AM', 'Guaporé', 336, 435, 'upcoming', 'In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.', '11/27/2025'),
  (12, 5, 26, 'Music Festival', '9/26/2025', '12:40 AM', 'Azenhas do Mar', 426, 21, 'completed', 'Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.\n\nCum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.\n\nEtiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.', '4/17/2026'),
  (13, 10, 6, 'Business Summit', '4/29/2026', '11:44 AM', 'Novonukutskiy', 275, 78, 'completed', 'Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.', '4/29/2026'),
  (14, 19, 50, 'Business Summit', '11/28/2025', '2:35 PM', 'Mullovka', 165, 176, 'upcoming', 'Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.\n\nNullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris.', '6/8/2025'),
  (15, 20, 42, 'Music Festival', '5/31/2025', '6:19 AM', 'Citeguh', 420, 372, 'completed', 'Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.\n\nMaecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.', '1/29/2026'),
  (16, 5, 13, 'Gaming Expo', '12/15/2025', '8:20 PM', 'Denver', 361, 233, 'cancelled', 'Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.\n\nVestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.\n\nIn congue. Etiam justo. Etiam pretium iaculis justo.', '10/1/2025'),
  (17, 17, 25, 'Music Festival', '6/5/2025', '11:21 PM', 'Youxi', 275, 8, 'completed', 'Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.\n\nQuisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.\n\nPhasellus in felis. Donec semper sapien a libero. Nam dui.', '7/28/2025'),
  (18, 14, 11, 'Health Seminar', '11/21/2025', '8:14 PM', 'Tongzha', 379, 227, 'completed', 'Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.', '12/25/2025'),
  (19, 7, 35, 'Startup Meetup', '11/27/2025', '1:05 AM', 'Daykitin', 216, 468, 'upcoming', 'Fusce consequat. Nulla nisl. Nunc nisl.', '3/26/2026'),
  (20, 9, 21, 'Startup Meetup', '8/2/2025', '4:55 AM', 'La Banda', 476, 30, 'upcoming', 'In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.', '11/28/2025'),
  (21, 14, 40, 'Tech Conference', '1/2/2026', '1:16 AM', 'Ust’-Koksa', 94, 356, 'upcoming', 'Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.\n\nIn congue. Etiam justo. Etiam pretium iaculis justo.', '1/10/2026'),
  (22, 17, 23, 'Fashion Show', '4/17/2026', '5:58 PM', 'Pszczew', 464, 128, 'upcoming', 'Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.', '3/8/2026'),
  (23, 11, 41, 'Business Summit', '1/5/2026', '4:52 PM', 'Chaupimarca', 81, 32, 'upcoming', 'Fusce consequat. Nulla nisl. Nunc nisl.', '4/26/2026'),
  (24, 4, 27, 'Gaming Expo', '10/3/2025', '10:32 AM', 'Sincelejo', 192, 458, 'upcoming', 'Phasellus in felis. Donec semper sapien a libero. Nam dui.', '9/23/2025'),
  (25, 6, 26, 'AI Workshop', '2/28/2026', '8:30 AM', 'Cela', 464, 340, 'cancelled', 'Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit.', '4/6/2026'),
  (26, 3, 34, 'Music Festival', '2/4/2026', '8:41 PM', 'Krajan', 209, 246, 'cancelled', 'Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.\n\nCras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.', '11/29/2025'),
  (27, 20, 32, 'Health Seminar', '9/7/2025', '3:01 AM', 'Ichinomiya', 413, 479, 'completed', 'Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris.', '12/6/2025'),
  (28, 18, 32, 'Gaming Expo', '5/12/2026', '10:08 AM', 'Mora', 421, 144, 'completed', 'Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.\n\nIn congue. Etiam justo. Etiam pretium iaculis justo.', '5/26/2025'),
  (29, 15, 22, 'Startup Meetup', '1/3/2026', '6:25 PM', 'Zaoxi', 187, 45, 'completed', 'Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.\n\nIn congue. Etiam justo. Etiam pretium iaculis justo.', '5/16/2025'),
  (30, 20, 41, 'Business Summit', '3/4/2026', '4:04 AM', 'Bako', 389, 118, 'cancelled', 'Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero.\n\nNullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.\n\nIn quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.', '9/14/2025'),
  (31, 3, 39, 'Gaming Expo', '3/1/2026', '10:14 PM', 'Oslo', 443, 333, 'completed', 'Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.\n\nMaecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.\n\nNullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris.', '1/11/2026'),
  (32, 16, 22, 'AI Workshop', '4/18/2026', '11:50 PM', 'Shankill', 317, 497, 'completed', 'Phasellus in felis. Donec semper sapien a libero. Nam dui.', '8/10/2025'),
  (33, 12, 42, 'Sports Tournament', '12/21/2025', '9:47 AM', 'Sápes', 50, 365, 'upcoming', 'Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.\n\nNam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.\n\nCurabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla. Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam.', '9/30/2025'),
  (34, 8, 36, 'Food Carnival', '9/25/2025', '3:28 AM', 'Shuiyang', 369, 461, 'upcoming', 'Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.\n\nMauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero.\n\nNullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.', '1/22/2026'),
  (35, 17, 33, 'Sports Tournament', '3/28/2026', '4:40 AM', 'Shiling', 415, 484, 'completed', 'Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis.', '1/22/2026'),
  (36, 13, 27, 'Health Seminar', '12/24/2025', '2:22 PM', 'Manjo', 318, 149, 'completed', 'In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.', '10/27/2025'),
  (37, 5, 37, 'Tech Conference', '2/22/2026', '1:21 PM', 'Mendī', 289, 3, 'cancelled', 'Sed ante. Vivamus tortor. Duis mattis egestas metus.\n\nAenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.\n\nQuisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.', '5/29/2025'),
  (38, 16, 7, 'Startup Meetup', '1/30/2026', '9:36 PM', 'Poříčí nad Sázavou', 142, 229, 'cancelled', 'Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.', '5/18/2025'),
  (39, 9, 19, 'Business Summit', '4/28/2026', '1:50 PM', 'Karlstad', 60, 466, 'completed', 'Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.\n\nQuisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.', '5/10/2026'),
  (40, 14, 29, 'Startup Meetup', '3/18/2026', '3:16 AM', 'Daying', 152, 41, 'cancelled', 'Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.', '9/20/2025'),
  (41, 13, 18, 'Fashion Show', '5/24/2025', '10:40 AM', 'Corinto', 127, 53, 'completed', 'Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.\n\nIn quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.', '10/20/2025'),
  (42, 4, 16, 'AI Workshop', '7/3/2025', '10:48 AM', 'Totora', 367, 311, 'completed', 'Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.\n\nCurabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla. Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam.', '5/24/2025'),
  (43, 17, 35, 'Food Carnival', '2/23/2026', '5:50 PM', 'Roissy Charles-de-Gaulle', 144, 388, 'cancelled', 'Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.', '11/27/2025'),
  (44, 19, 45, 'Business Summit', '12/27/2025', '12:20 AM', 'Dąbrowa', 283, 73, 'completed', 'In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.', '1/30/2026'),
  (45, 1, 31, 'Health Seminar', '12/28/2025', '9:11 AM', 'Kralupy nad Vltavou', 421, 215, 'upcoming', 'Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.', '2/8/2026'),
  (46, 6, 38, 'Business Summit', '11/16/2025', '8:11 AM', 'Catungawan Sur', 328, 416, 'completed', 'Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.', '5/18/2025'),
  (47, 11, 27, 'Startup Meetup', '12/26/2025', '3:13 PM', 'Shijiazhuang', 271, 293, 'upcoming', 'Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.\n\nPellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.\n\nCum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.', '11/9/2025'),
  (48, 4, 14, 'Tech Conference', '1/31/2026', '1:54 AM', 'Kuching', 414, 348, 'completed', 'In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.', '9/10/2025'),
  (49, 20, 16, 'Fashion Show', '6/30/2025', '8:09 PM', 'Tancheng', 491, 379, 'upcoming', 'Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero.', '2/14/2026'),
  (50, 3, 39, 'Fashion Show', '8/2/2025', '10:03 PM', 'Leduc', 464, 97, 'upcoming', 'Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.', '2/15/2026'),
  (51, 10, 7, 'Health Seminar', '6/21/2025', '8:12 AM', 'Hisings Kärra', 445, 377, 'completed', 'Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.', '7/7/2025'),
  (52, 4, 10, 'Gaming Expo', '2/11/2026', '11:00 PM', 'Gondanglegi Wetan', 147, 34, 'upcoming', 'In congue. Etiam justo. Etiam pretium iaculis justo.\n\nIn hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.', '11/16/2025'),
  (53, 14, 21, 'Music Festival', '5/30/2025', '7:25 AM', 'Kertasari', 225, 347, 'cancelled', 'Sed ante. Vivamus tortor. Duis mattis egestas metus.\n\nAenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.', '1/22/2026'),
  (54, 10, 3, 'Fashion Show', '1/25/2026', '8:54 PM', 'Zarechnyy', 155, 46, 'upcoming', 'Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.\n\nPraesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.', '10/31/2025'),
  (55, 7, 14, 'Business Summit', '7/23/2025', '10:42 AM', 'Pulap', 89, 134, 'upcoming', 'Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.\n\nNam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.\n\nCurabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla. Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam.', '2/15/2026'),
  (56, 12, 37, 'Startup Meetup', '1/22/2026', '1:28 PM', 'Uherce Mineralne', 92, 426, 'cancelled', 'Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.\n\nPhasellus in felis. Donec semper sapien a libero. Nam dui.', '7/18/2025'),
  (57, 12, 29, 'Health Seminar', '8/13/2025', '2:55 AM', 'Gwoźnica Górna', 426, 267, 'upcoming', 'Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.', '7/6/2025'),
  (58, 9, 1, 'Music Festival', '5/5/2026', '2:48 AM', 'Nuevo Chamelecón', 476, 157, 'upcoming', 'Sed ante. Vivamus tortor. Duis mattis egestas metus.', '5/25/2025'),
  (59, 18, 38, 'Fashion Show', '10/1/2025', '3:52 AM', 'Laozhuang', 358, 255, 'completed', 'Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris.\n\nMorbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.\n\nFusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.', '4/11/2026'),
  (60, 12, 5, 'Health Seminar', '9/28/2025', '11:53 PM', 'Chybie', 453, 399, 'cancelled', 'Phasellus in felis. Donec semper sapien a libero. Nam dui.\n\nProin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.', '10/6/2025'),
  (61, 5, 4, 'Health Seminar', '3/25/2026', '9:55 AM', 'Lena', 73, 462, 'upcoming', 'Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.', '8/4/2025'),
  (62, 17, 6, 'Fashion Show', '11/8/2025', '10:10 AM', 'Xufu', 305, 266, 'cancelled', 'Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.\n\nNam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.\n\nCurabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla. Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam.', '9/8/2025'),
  (63, 12, 13, 'Gaming Expo', '4/28/2026', '9:02 AM', 'Aras-asan', 266, 286, 'completed', 'Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.\n\nFusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.', '9/16/2025'),
  (64, 8, 9, 'Music Festival', '9/25/2025', '6:28 AM', 'Ashiya', 187, 461, 'completed', 'In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.', '5/31/2025'),
  (65, 3, 40, 'Sports Tournament', '6/8/2025', '4:17 AM', 'Bancak Wetan', 487, 54, 'completed', 'Phasellus in felis. Donec semper sapien a libero. Nam dui.\n\nProin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.\n\nInteger ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.', '12/12/2025'),
  (66, 7, 10, 'Tech Conference', '3/24/2026', '11:22 PM', 'Tranås', 387, 123, 'upcoming', 'Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.\n\nQuisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.', '2/27/2026'),
  (67, 15, 45, 'Food Carnival', '5/31/2025', '8:15 AM', 'Al ‘Āqir', 59, 187, 'upcoming', 'Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.\n\nInteger ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.\n\nNam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.', '5/27/2025'),
  (68, 15, 4, 'Music Festival', '5/19/2025', '12:43 PM', 'Stalís', 372, 436, 'upcoming', 'Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.', '9/2/2025'),
  (69, 1, 24, 'Fashion Show', '9/27/2025', '12:25 AM', 'Cilampuyang', 241, 3, 'cancelled', 'Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.\n\nNullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris.', '7/2/2025'),
  (70, 6, 50, 'AI Workshop', '10/16/2025', '9:42 AM', 'Dordrecht', 470, 467, 'cancelled', 'Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.', '5/8/2026'),
  (71, 20, 11, 'AI Workshop', '5/6/2026', '10:40 PM', 'Velké Meziříčí', 152, 1, 'cancelled', 'Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.', '4/7/2026'),
  (72, 9, 41, 'Startup Meetup', '4/25/2026', '3:55 AM', 'Aguilar', 274, 222, 'cancelled', 'Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.', '9/4/2025'),
  (73, 12, 23, 'Tech Conference', '1/31/2026', '12:58 PM', 'Tuusniemi', 354, 346, 'cancelled', 'Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.\n\nQuisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.', '5/16/2025'),
  (74, 12, 44, 'Sports Tournament', '8/26/2025', '7:15 PM', 'Kombësi', 291, 368, 'cancelled', 'Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.', '7/11/2025'),
  (75, 15, 21, 'Gaming Expo', '3/16/2026', '6:47 AM', 'Huadian', 322, 200, 'cancelled', 'Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.', '10/14/2025'),
  (76, 8, 12, 'Business Summit', '1/2/2026', '11:53 AM', 'Nepomuceno', 161, 396, 'completed', 'Fusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.', '12/10/2025'),
  (77, 2, 38, 'Tech Conference', '11/27/2025', '12:49 AM', 'Xinglong', 439, 239, 'cancelled', 'In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.', '6/10/2025'),
  (78, 18, 11, 'Music Festival', '5/30/2025', '12:35 PM', 'Taiping', 402, 375, 'upcoming', 'In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.', '2/12/2026'),
  (79, 20, 23, 'Music Festival', '5/1/2026', '11:02 PM', 'Jarošov nad Nežárkou', 322, 19, 'upcoming', 'Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.', '5/26/2025'),
  (80, 14, 22, 'Food Carnival', '6/25/2025', '5:31 PM', 'Bacuyangan', 231, 166, 'completed', 'Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.', '9/8/2025'),
  (81, 13, 14, 'Music Festival', '3/16/2026', '8:45 AM', 'Bicaj', 77, 429, 'completed', 'Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.', '7/5/2025'),
  (82, 7, 15, 'Tech Conference', '5/21/2025', '3:53 AM', 'Kalayemule', 322, 46, 'cancelled', 'Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.', '3/6/2026'),
  (83, 17, 43, 'Fashion Show', '4/29/2026', '2:58 PM', 'Zhongzuiling', 455, 84, 'cancelled', 'Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.', '5/12/2026'),
  (84, 10, 18, 'Tech Conference', '5/11/2026', '6:54 AM', 'Hengdong Chengguanzhen', 450, 157, 'completed', 'In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.', '4/4/2026'),
  (85, 7, 4, 'Music Festival', '6/8/2025', '1:52 PM', 'Sungailiat', 159, 92, 'cancelled', 'Fusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.', '4/28/2026'),
  (86, 6, 22, 'Sports Tournament', '6/7/2025', '10:21 AM', 'Wufeng', 154, 236, 'completed', 'Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.', '9/13/2025'),
  (87, 5, 43, 'Sports Tournament', '2/4/2026', '6:40 PM', 'Beisijia', 487, 242, 'upcoming', 'Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis.\n\nDuis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.', '6/8/2025'),
  (88, 16, 7, 'Sports Tournament', '1/17/2026', '11:00 AM', 'Wilmington', 138, 64, 'completed', 'Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.', '9/29/2025'),
  (89, 17, 12, 'Business Summit', '10/1/2025', '2:43 AM', 'Xai-Xai', 477, 147, 'cancelled', 'Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.\n\nMauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero.', '3/16/2026'),
  (90, 5, 35, 'Music Festival', '4/27/2026', '12:58 AM', 'Verkhnyaya Tura', 135, 74, 'upcoming', 'Fusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.', '8/29/2025'),
  (91, 5, 48, 'Business Summit', '4/16/2026', '8:57 AM', 'Zhanghua', 182, 213, 'upcoming', 'Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.', '5/16/2025'),
  (92, 15, 27, 'AI Workshop', '6/29/2025', '3:11 AM', 'Bundibugyo', 386, 32, 'completed', 'Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.\n\nNam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.\n\nCurabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla. Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam.', '7/7/2025'),
  (93, 8, 9, 'Business Summit', '1/22/2026', '7:15 PM', 'Chenqiao', 287, 111, 'upcoming', 'Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.', '10/11/2025'),
  (94, 11, 22, 'Health Seminar', '9/14/2025', '12:43 AM', 'Zigong', 169, 465, 'cancelled', 'Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.', '10/28/2025'),
  (95, 8, 22, 'AI Workshop', '4/14/2026', '9:02 AM', 'Castanheira de Pêra', 453, 229, 'upcoming', 'Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.', '4/9/2026'),
  (96, 7, 22, 'AI Workshop', '12/16/2025', '6:29 AM', 'Ospina', 258, 400, 'completed', 'Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.\n\nPhasellus in felis. Donec semper sapien a libero. Nam dui.', '9/11/2025'),
  (97, 19, 38, 'Gaming Expo', '7/20/2025', '7:54 PM', 'Bobigny', 340, 44, 'upcoming', 'Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.', '6/9/2025'),
  (98, 10, 2, 'Gaming Expo', '12/7/2025', '10:56 PM', 'Languan', 320, 364, 'upcoming', 'Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.', '4/21/2026'),
  (99, 14, 41, 'Health Seminar', '1/12/2026', '9:53 AM', 'Kaiyuan', 319, 455, 'completed', 'Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis.\n\nDuis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.', '9/19/2025'),
  (100, 3, 32, 'Startup Meetup', '5/2/2026', '1:19 AM', 'Minsk', 488, 433, 'upcoming', 'Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.', '12/3/2025');

-- =============================================================================
-- INSERT: Bookings (200 rows)
-- =============================================================================
INSERT INTO Bookings (booking_id, user_id, event_id, seats_booked, booking_status, booking_date, notes) VALUES
  (1, 14, 82, 2, 'cancelled', '3/16/2026', 'Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque. Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus. Phasellus in felis. Donec semper sapien a libero. Nam dui. Proin leo odio, porttitor id, consequat in, consequat ut, nulla.'),
  (2, 16, 55, 9, 'pending', '11/5/2025', 'Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat. Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede. Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.'),
  (3, 15, 24, 7, 'pending', '4/4/2026', 'Integer a nibh. In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet. Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui. Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc.'),
  (4, 15, 36, 1, 'confirmed', '1/4/2026', 'Aenean lectus.'),
  (5, 14, 18, 5, 'pending', '12/15/2025', 'Donec quis orci eget orci vehicula condimentum. Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est. Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.'),
  (6, 3, 22, 1, 'cancelled', '1/25/2026', 'Donec semper sapien a libero. Nam dui. Proin leo odio, porttitor id, consequat in, consequat ut, nulla.'),
  (7, 9, 4, 3, 'cancelled', '1/21/2026', 'In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue.'),
  (8, 10, 38, 5, 'confirmed', '6/25/2025', 'Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat. In congue. Etiam justo. Etiam pretium iaculis justo.'),
  (9, 17, 83, 10, 'confirmed', '4/16/2026', 'Vivamus vel nulla eget eros elementum pellentesque. Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus. Phasellus in felis. Donec semper sapien a libero. Nam dui. Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis.'),
  (10, 20, 30, 6, 'pending', '5/23/2025', 'Aenean auctor gravida sem. Praesent id massa id nisl venenatis lacinia.'),
  (11, 11, 58, 5, 'pending', '7/29/2025', 'Duis mattis egestas metus. Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh. Quisque id justo sit amet sapien dignissim vestibulum.'),
  (12, 5, 32, 10, 'confirmed', '11/4/2025', 'Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh. Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros. Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat. In congue.'),
  (13, 10, 25, 4, 'pending', '7/21/2025', 'Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis. Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.'),
  (14, 19, 7, 8, 'cancelled', '1/16/2026', 'Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem. Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio. Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.'),
  (15, 1, 100, 4, 'confirmed', '7/17/2025', 'Mauris lacinia sapien quis libero. Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.'),
  (16, 8, 93, 6, 'cancelled', '2/1/2026', 'Vivamus in felis eu sapien cursus vestibulum.'),
  (17, 10, 67, 6, 'cancelled', '7/29/2025', 'In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet. Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui. Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.'),
  (18, 13, 27, 3, 'confirmed', '5/11/2026', 'In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet. Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo.'),
  (19, 13, 9, 9, 'pending', '12/13/2025', 'Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl. Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum. Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.'),
  (20, 3, 90, 10, 'cancelled', '3/9/2026', 'Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede. Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem. Fusce consequat. Nulla nisl. Nunc nisl. Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa.'),
  (21, 14, 56, 3, 'pending', '6/25/2025', 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin risus. Praesent lectus. Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis.'),
  (22, 12, 26, 7, 'cancelled', '8/7/2025', 'Donec semper sapien a libero. Nam dui. Proin leo odio, porttitor id, consequat in, consequat ut, nulla.'),
  (23, 9, 46, 5, 'confirmed', '6/24/2025', 'Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus. Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst. Maecenas ut massa quis augue luctus tincidunt.'),
  (24, 15, 7, 8, 'pending', '3/25/2026', 'Vivamus tortor.'),
  (25, 14, 86, 9, 'pending', '10/2/2025', 'Quisque ut erat. Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem. Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat. Praesent blandit.'),
  (26, 19, 41, 9, 'confirmed', '8/25/2025', 'Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus. Curabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla. Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam. Nam tristique tortor eu pede.'),
  (27, 19, 35, 8, 'confirmed', '10/17/2025', 'Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem. Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.'),
  (28, 16, 71, 3, 'pending', '9/14/2025', 'Morbi vel lectus in quam fringilla rhoncus. Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero.'),
  (29, 7, 99, 10, 'confirmed', '12/10/2025', 'Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est. Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum. Proin eu mi.'),
  (30, 13, 17, 4, 'confirmed', '6/22/2025', 'Sed vel enim sit amet nunc viverra dapibus.'),
  (31, 12, 38, 7, 'confirmed', '8/20/2025', 'In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.'),
  (32, 16, 6, 10, 'cancelled', '10/9/2025', 'Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem. Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus. Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.'),
  (33, 1, 69, 5, 'cancelled', '12/27/2025', 'Suspendisse potenti. Cras in purus eu magna vulputate luctus. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem. Praesent id massa id nisl venenatis lacinia.'),
  (34, 14, 25, 3, 'cancelled', '10/10/2025', 'Aenean auctor gravida sem. Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio. Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue.'),
  (35, 8, 2, 5, 'cancelled', '2/26/2026', 'Vivamus tortor. Duis mattis egestas metus. Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh. Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est.'),
  (36, 4, 90, 7, 'confirmed', '3/6/2026', 'Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus. Phasellus in felis. Donec semper sapien a libero. Nam dui. Proin leo odio, porttitor id, consequat in, consequat ut, nulla.'),
  (37, 4, 53, 8, 'confirmed', '5/20/2025', 'In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo. Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis. Sed ante. Vivamus tortor. Duis mattis egestas metus. Aenean fermentum.'),
  (38, 13, 11, 3, 'cancelled', '4/10/2026', 'Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero. Nullam sit amet turpis elementum ligula vehicula consequat.'),
  (39, 9, 59, 9, 'cancelled', '8/6/2025', 'Aenean sit amet justo. Morbi ut odio. Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin interdum mauris non ligula pellentesque ultrices.'),
  (40, 6, 73, 9, 'cancelled', '12/16/2025', 'Duis mattis egestas metus. Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh. Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros. Vestibulum ac est lacinia nisi venenatis tristique.'),
  (41, 5, 34, 3, 'cancelled', '6/27/2025', 'Ut at dolor quis odio consequat varius. Integer ac leo. Pellentesque ultrices mattis odio.'),
  (42, 3, 86, 9, 'confirmed', '5/27/2025', 'Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus. Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst. Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem.'),
  (43, 9, 38, 8, 'cancelled', '4/28/2026', 'Donec posuere metus vitae ipsum. Aliquam non mauris. Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis. Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem. Sed sagittis.'),
  (44, 5, 73, 7, 'cancelled', '1/27/2026', 'Vivamus tortor. Duis mattis egestas metus. Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh. Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.'),
  (45, 3, 34, 2, 'pending', '1/1/2026', 'Donec posuere metus vitae ipsum. Aliquam non mauris. Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis. Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem. Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci.'),
  (46, 14, 77, 6, 'pending', '5/3/2026', 'Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis. Sed ante. Vivamus tortor. Duis mattis egestas metus. Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.'),
  (47, 12, 65, 2, 'pending', '3/3/2026', 'Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem. Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat.'),
  (48, 6, 67, 4, 'pending', '10/3/2025', 'Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero. Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.'),
  (49, 15, 65, 8, 'pending', '1/1/2026', 'In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo. Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis. Sed ante. Vivamus tortor. Duis mattis egestas metus. Aenean fermentum.'),
  (50, 10, 54, 7, 'cancelled', '11/14/2025', 'Nulla tellus. In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus. Suspendisse potenti.'),
  (51, 11, 44, 10, 'confirmed', '6/17/2025', 'Morbi ut odio. Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl. Aenean lectus.'),
  (52, 16, 43, 6, 'confirmed', '4/30/2026', 'Nulla nisl. Nunc nisl. Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa.'),
  (53, 6, 46, 2, 'confirmed', '5/4/2026', 'Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh. Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros. Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue.'),
  (54, 11, 8, 4, 'confirmed', '9/15/2025', 'Sed accumsan felis. Ut at dolor quis odio consequat varius. Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi. Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus. Curabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla.'),
  (55, 10, 89, 5, 'pending', '12/11/2025', 'Morbi vel lectus in quam fringilla rhoncus. Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero. Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh. In quis justo. Maecenas rhoncus aliquam lacus.'),
  (56, 4, 26, 10, 'confirmed', '3/27/2026', 'Vestibulum rutrum rutrum neque. Aenean auctor gravida sem. Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio. Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim.'),
  (57, 4, 28, 2, 'cancelled', '8/24/2025', 'Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl. Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.'),
  (58, 1, 89, 8, 'confirmed', '11/19/2025', 'In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet. Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui. Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti. Nullam porttitor lacus at turpis.'),
  (59, 1, 53, 1, 'pending', '4/8/2026', 'Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est. Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum. Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.'),
  (60, 3, 87, 2, 'confirmed', '3/27/2026', 'Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum.'),
  (61, 5, 84, 8, 'confirmed', '2/6/2026', 'Mauris sit amet eros. Suspendisse accumsan tortor quis turpis. Sed ante. Vivamus tortor.'),
  (62, 18, 3, 9, 'pending', '7/22/2025', 'Donec semper sapien a libero. Nam dui. Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.'),
  (63, 6, 25, 5, 'confirmed', '7/30/2025', 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros. Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue.'),
  (64, 15, 31, 1, 'confirmed', '2/7/2026', 'Nunc rhoncus dui vel sem. Sed sagittis.'),
  (65, 20, 97, 8, 'pending', '2/21/2026', 'Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris. Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis. Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl.'),
  (66, 4, 64, 2, 'confirmed', '8/3/2025', 'Integer a nibh. In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet. Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo.'),
  (67, 17, 90, 10, 'confirmed', '11/30/2025', 'Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci.'),
  (68, 13, 48, 7, 'confirmed', '6/10/2025', 'Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est. Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum. Proin eu mi. Nulla ac enim.'),
  (69, 1, 90, 5, 'confirmed', '1/20/2026', 'Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum. Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est. Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum. Proin eu mi. Nulla ac enim.'),
  (70, 14, 3, 1, 'cancelled', '5/29/2025', 'Vestibulum sed magna at nunc commodo placerat. Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede. Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem. Fusce consequat. Nulla nisl. Nunc nisl.'),
  (71, 4, 11, 3, 'cancelled', '4/15/2026', 'Suspendisse accumsan tortor quis turpis. Sed ante. Vivamus tortor. Duis mattis egestas metus. Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh. Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est.'),
  (72, 14, 72, 4, 'confirmed', '5/17/2025', 'Vivamus vel nulla eget eros elementum pellentesque. Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus. Phasellus in felis. Donec semper sapien a libero. Nam dui. Proin leo odio, porttitor id, consequat in, consequat ut, nulla.'),
  (73, 17, 100, 2, 'confirmed', '6/5/2025', 'Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet. Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.'),
  (74, 1, 23, 8, 'pending', '2/11/2026', 'Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh. Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros. Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat. In congue.'),
  (75, 6, 44, 1, 'pending', '4/27/2026', 'Duis at velit eu est congue elementum. In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo. Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis.'),
  (76, 14, 34, 2, 'cancelled', '2/25/2026', 'Sed ante. Vivamus tortor. Duis mattis egestas metus. Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh. Quisque id justo sit amet sapien dignissim vestibulum.'),
  (77, 5, 56, 6, 'cancelled', '2/7/2026', 'Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo.'),
  (78, 2, 31, 9, 'pending', '9/22/2025', 'Donec semper sapien a libero. Nam dui. Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.'),
  (79, 14, 98, 7, 'confirmed', '6/14/2025', 'Duis at velit eu est congue elementum.'),
  (80, 14, 80, 6, 'confirmed', '4/26/2026', 'Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est. Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum. Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem. Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy.'),
  (81, 18, 18, 9, 'confirmed', '8/11/2025', 'Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est. Phasellus sit amet erat.'),
  (82, 4, 73, 8, 'cancelled', '4/22/2026', 'Donec posuere metus vitae ipsum. Aliquam non mauris. Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis. Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl.'),
  (83, 16, 32, 6, 'pending', '10/3/2025', 'Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus.'),
  (84, 13, 25, 7, 'cancelled', '8/3/2025', 'Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum. Curabitur in libero ut massa volutpat convallis.'),
  (85, 15, 74, 10, 'cancelled', '6/20/2025', 'In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus. Nulla ut erat id mauris vulputate elementum.'),
  (86, 10, 39, 2, 'cancelled', '11/7/2025', 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis. Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.'),
  (87, 13, 13, 8, 'cancelled', '11/23/2025', 'Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros. Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat. In congue. Etiam justo. Etiam pretium iaculis justo. In hac habitasse platea dictumst.'),
  (88, 6, 81, 6, 'confirmed', '2/8/2026', 'Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus. Phasellus in felis. Donec semper sapien a libero. Nam dui. Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.'),
  (89, 18, 21, 4, 'pending', '4/7/2026', 'In congue. Etiam justo. Etiam pretium iaculis justo. In hac habitasse platea dictumst. Etiam faucibus cursus urna.'),
  (90, 17, 26, 10, 'pending', '10/18/2025', 'Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus. Curabitur at ipsum ac tellus semper interdum.'),
  (91, 9, 90, 6, 'pending', '1/22/2026', 'Suspendisse accumsan tortor quis turpis. Sed ante. Vivamus tortor. Duis mattis egestas metus. Aenean fermentum.'),
  (92, 10, 7, 5, 'cancelled', '2/7/2026', 'Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.'),
  (93, 19, 15, 8, 'pending', '11/12/2025', 'Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet. Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo.'),
  (94, 16, 40, 9, 'pending', '8/12/2025', 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque. Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.'),
  (95, 3, 53, 8, 'cancelled', '9/22/2025', 'Etiam justo. Etiam pretium iaculis justo.'),
  (96, 8, 83, 5, 'pending', '4/14/2026', 'Nunc rhoncus dui vel sem. Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus. Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.'),
  (97, 3, 59, 2, 'confirmed', '6/29/2025', 'Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem. Fusce consequat. Nulla nisl.'),
  (98, 14, 54, 6, 'cancelled', '9/20/2025', 'Ut at dolor quis odio consequat varius. Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.'),
  (99, 18, 4, 3, 'confirmed', '1/3/2026', 'Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit. Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque. Duis bibendum. Morbi non quam nec dui luctus rutrum.'),
  (100, 20, 38, 7, 'confirmed', '2/8/2026', 'Maecenas pulvinar lobortis est. Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum. Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem. Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy.'),
  (101, 11, 61, 5, 'confirmed', '2/18/2026', 'Duis at velit eu est congue elementum. In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo. Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis. Sed ante. Vivamus tortor. Duis mattis egestas metus.'),
  (102, 14, 36, 6, 'pending', '9/2/2025', 'Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat. Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede. Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.'),
  (103, 14, 57, 10, 'confirmed', '2/13/2026', 'Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat. In congue. Etiam justo.'),
  (104, 13, 30, 3, 'pending', '2/12/2026', 'Duis at velit eu est congue elementum. In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo. Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis.'),
  (105, 16, 54, 3, 'cancelled', '1/3/2026', 'In hac habitasse platea dictumst. Maecenas ut massa quis augue luctus tincidunt.'),
  (106, 15, 49, 5, 'confirmed', '7/6/2025', 'Donec quis orci eget orci vehicula condimentum. Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est. Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum. Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.'),
  (107, 2, 80, 8, 'cancelled', '8/8/2025', 'Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc.'),
  (108, 12, 9, 1, 'cancelled', '11/29/2025', 'Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien.'),
  (109, 13, 44, 4, 'confirmed', '4/30/2026', 'Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem. Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus. Pellentesque at nulla.'),
  (110, 5, 81, 9, 'confirmed', '1/18/2026', 'Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros. Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.'),
  (111, 16, 62, 10, 'confirmed', '8/14/2025', 'Phasellus id sapien in sapien iaculis congue.'),
  (112, 19, 97, 1, 'confirmed', '6/21/2025', 'Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit.'),
  (113, 17, 55, 1, 'confirmed', '3/26/2026', 'Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus. Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero. Nullam sit amet turpis elementum ligula vehicula consequat.'),
  (114, 3, 14, 3, 'confirmed', '2/27/2026', 'Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo.'),
  (115, 14, 72, 4, 'pending', '9/1/2025', 'Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh. Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros. Vestibulum ac est lacinia nisi venenatis tristique.'),
  (116, 9, 62, 5, 'pending', '5/9/2026', 'Aenean fermentum. Donec ut mauris eget massa tempor convallis.'),
  (117, 10, 53, 10, 'cancelled', '2/10/2026', 'Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros. Vestibulum ac est lacinia nisi venenatis tristique.'),
  (118, 13, 41, 2, 'cancelled', '4/1/2026', 'Phasellus sit amet erat. Nulla tempus.'),
  (119, 6, 85, 4, 'pending', '1/29/2026', 'Quisque ut erat. Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem. Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat. Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.'),
  (120, 9, 92, 4, 'cancelled', '2/26/2026', 'Cras in purus eu magna vulputate luctus. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.'),
  (121, 6, 68, 4, 'confirmed', '1/25/2026', 'Nam dui.'),
  (122, 1, 44, 10, 'pending', '6/17/2025', 'Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus. Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero. Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh. In quis justo.'),
  (123, 18, 58, 4, 'pending', '6/12/2025', 'Vivamus in felis eu sapien cursus vestibulum. Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.'),
  (124, 20, 81, 7, 'pending', '9/3/2025', 'Pellentesque ultrices mattis odio. Donec vitae nisi. Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.'),
  (125, 11, 91, 2, 'confirmed', '11/13/2025', 'Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede. Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.'),
  (126, 11, 69, 7, 'cancelled', '7/25/2025', 'In est risus, auctor sed, tristique in, tempus sit amet, sem. Fusce consequat. Nulla nisl.'),
  (127, 16, 17, 8, 'confirmed', '5/17/2025', 'Cras pellentesque volutpat dui. Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti. Nullam porttitor lacus at turpis.'),
  (128, 2, 45, 10, 'confirmed', '5/26/2025', 'Vivamus tortor. Duis mattis egestas metus. Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh. Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros. Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue.'),
  (129, 1, 27, 10, 'pending', '4/21/2026', 'Maecenas pulvinar lobortis est. Phasellus sit amet erat. Nulla tempus.'),
  (130, 5, 1, 8, 'pending', '3/16/2026', 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis.'),
  (131, 1, 50, 6, 'confirmed', '10/28/2025', 'Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh. Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros. Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.'),
  (132, 19, 55, 1, 'confirmed', '11/9/2025', 'Morbi a ipsum. Integer a nibh. In quis justo.'),
  (133, 14, 13, 5, 'confirmed', '11/30/2025', 'Vestibulum sed magna at nunc commodo placerat. Praesent blandit. Nam nulla.'),
  (134, 4, 64, 4, 'confirmed', '4/12/2026', 'Nulla tellus. In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus. Suspendisse potenti.'),
  (135, 17, 25, 4, 'confirmed', '9/5/2025', 'Vivamus vel nulla eget eros elementum pellentesque. Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus. Phasellus in felis. Donec semper sapien a libero. Nam dui. Proin leo odio, porttitor id, consequat in, consequat ut, nulla.'),
  (136, 9, 22, 3, 'cancelled', '8/11/2025', 'Nullam varius. Nulla facilisi. Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.'),
  (137, 15, 15, 7, 'confirmed', '5/12/2026', 'Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum. Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est. Phasellus sit amet erat.'),
  (138, 13, 91, 1, 'pending', '4/19/2026', 'Vivamus tortor. Duis mattis egestas metus.'),
  (139, 8, 96, 3, 'pending', '4/11/2026', 'Morbi non quam nec dui luctus rutrum. Nulla tellus. In sagittis dui vel nisl.'),
  (140, 4, 54, 3, 'confirmed', '6/15/2025', 'Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui. Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti. Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris. Morbi non lectus.'),
  (141, 12, 62, 5, 'cancelled', '5/12/2026', 'Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem. Fusce consequat. Nulla nisl. Nunc nisl.'),
  (142, 4, 58, 4, 'pending', '5/1/2026', 'Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus. Pellentesque at nulla.'),
  (143, 12, 17, 8, 'confirmed', '9/29/2025', 'Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl. Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum. Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.'),
  (144, 19, 30, 9, 'cancelled', '4/18/2026', 'Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus. Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci.'),
  (145, 14, 75, 3, 'cancelled', '7/13/2025', 'Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.'),
  (146, 4, 80, 7, 'cancelled', '4/17/2026', 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros. Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat. In congue. Etiam justo. Etiam pretium iaculis justo.'),
  (147, 11, 76, 2, 'confirmed', '11/12/2025', 'Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.'),
  (148, 15, 77, 10, 'confirmed', '2/26/2026', 'In congue. Etiam justo. Etiam pretium iaculis justo. In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus. Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi. Cras non velit nec nisi vulputate nonummy.'),
  (149, 14, 2, 8, 'pending', '3/28/2026', 'Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui. Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.'),
  (150, 1, 24, 5, 'confirmed', '8/7/2025', 'Vestibulum rutrum rutrum neque. Aenean auctor gravida sem. Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio. Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim.'),
  (151, 9, 80, 7, 'pending', '10/30/2025', 'Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo. Aliquam quis turpis eget elit sodales scelerisque.'),
  (152, 17, 64, 4, 'cancelled', '6/11/2025', 'Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.'),
  (153, 16, 41, 9, 'pending', '9/30/2025', 'Morbi vel lectus in quam fringilla rhoncus. Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero. Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.'),
  (154, 7, 9, 6, 'pending', '5/2/2026', 'Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem. Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.'),
  (155, 14, 98, 8, 'confirmed', '8/9/2025', 'Integer a nibh. In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet. Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam.'),
  (156, 4, 8, 5, 'confirmed', '5/13/2026', 'Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque. Quisque porta volutpat erat.'),
  (157, 11, 44, 8, 'pending', '11/22/2025', 'In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem. Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat. Praesent blandit. Nam nulla.'),
  (158, 18, 77, 3, 'confirmed', '4/7/2026', 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis. Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus. Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero. Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum.'),
  (159, 8, 22, 10, 'pending', '6/26/2025', 'Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum. Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem. Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit. Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue.'),
  (160, 12, 14, 4, 'pending', '7/4/2025', 'Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam. Nam tristique tortor eu pede.'),
  (161, 19, 23, 2, 'pending', '4/20/2026', 'Suspendisse potenti. Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris. Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis. Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.'),
  (162, 16, 90, 9, 'confirmed', '2/6/2026', 'In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante.'),
  (163, 8, 85, 1, 'cancelled', '1/15/2026', 'Integer non velit. Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi.'),
  (164, 20, 31, 10, 'pending', '4/13/2026', 'Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo. Aliquam quis turpis eget elit sodales scelerisque.'),
  (165, 6, 82, 7, 'pending', '9/29/2025', 'Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl. Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum. Curabitur in libero ut massa volutpat convallis.'),
  (166, 8, 62, 4, 'pending', '6/20/2025', 'Vivamus in felis eu sapien cursus vestibulum.'),
  (167, 13, 42, 6, 'pending', '3/2/2026', 'Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros.'),
  (168, 18, 54, 9, 'cancelled', '8/26/2025', 'In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet. Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui. Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti. Nullam porttitor lacus at turpis.'),
  (169, 15, 38, 6, 'cancelled', '12/14/2025', 'Nunc purus. Phasellus in felis. Donec semper sapien a libero. Nam dui. Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.'),
  (170, 11, 48, 3, 'confirmed', '11/30/2025', 'Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui. Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.'),
  (171, 8, 69, 10, 'pending', '4/18/2026', 'Ut at dolor quis odio consequat varius. Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi. Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus. Curabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla.'),
  (172, 13, 38, 6, 'pending', '4/26/2026', 'Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem. Fusce consequat. Nulla nisl. Nunc nisl. Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa.'),
  (173, 1, 63, 9, 'cancelled', '9/17/2025', 'Sed accumsan felis. Ut at dolor quis odio consequat varius. Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi. Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus.'),
  (174, 6, 94, 1, 'confirmed', '9/15/2025', 'Duis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.'),
  (175, 17, 78, 5, 'pending', '1/22/2026', 'Vivamus tortor. Duis mattis egestas metus. Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh. Quisque id justo sit amet sapien dignissim vestibulum.'),
  (176, 8, 69, 3, 'cancelled', '5/26/2025', 'Nulla ut erat id mauris vulputate elementum.'),
  (177, 14, 14, 5, 'pending', '5/5/2026', 'Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.'),
  (178, 8, 30, 4, 'pending', '1/22/2026', 'In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet. Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui. Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc.'),
  (179, 17, 31, 3, 'pending', '9/24/2025', 'Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus. Pellentesque at nulla.'),
  (180, 1, 23, 10, 'cancelled', '12/9/2025', 'Fusce consequat. Nulla nisl. Nunc nisl. Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum. In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.'),
  (181, 1, 18, 6, 'confirmed', '12/7/2025', 'Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh. In quis justo. Maecenas rhoncus aliquam lacus.'),
  (182, 3, 10, 1, 'cancelled', '5/19/2025', 'Proin at turpis a pede posuere nonummy. Integer non velit. Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque. Duis bibendum.'),
  (183, 2, 11, 5, 'pending', '6/11/2025', 'Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat. In congue. Etiam justo. Etiam pretium iaculis justo.'),
  (184, 6, 65, 9, 'pending', '2/12/2026', 'Morbi ut odio. Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin interdum mauris non ligula pellentesque ultrices.'),
  (185, 6, 88, 10, 'cancelled', '8/9/2025', 'Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus. Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci.'),
  (186, 12, 19, 2, 'pending', '9/5/2025', 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl. Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum. Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.'),
  (187, 5, 56, 6, 'cancelled', '10/15/2025', 'Aenean sit amet justo. Morbi ut odio. Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl. Aenean lectus.'),
  (188, 8, 27, 5, 'cancelled', '7/25/2025', 'Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.'),
  (189, 16, 51, 3, 'confirmed', '3/4/2026', 'Nullam porttitor lacus at turpis.'),
  (190, 11, 3, 3, 'confirmed', '12/22/2025', 'Nulla mollis molestie lorem. Quisque ut erat. Curabitur gravida nisi at nibh.'),
  (191, 10, 62, 9, 'confirmed', '8/7/2025', 'In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus. Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst. Maecenas ut massa quis augue luctus tincidunt.'),
  (192, 1, 86, 3, 'cancelled', '12/7/2025', 'Mauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero. Nullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh. In quis justo. Maecenas rhoncus aliquam lacus.'),
  (193, 17, 20, 3, 'confirmed', '3/8/2026', 'Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue.'),
  (194, 1, 62, 1, 'pending', '10/8/2025', 'Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros. Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.'),
  (195, 20, 82, 10, 'pending', '3/7/2026', 'Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem. Fusce consequat. Nulla nisl. Nunc nisl. Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.'),
  (196, 9, 74, 2, 'cancelled', '4/18/2026', 'Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus. Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst. Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat. Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.'),
  (197, 3, 93, 3, 'cancelled', '9/17/2025', 'Quisque porta volutpat erat.'),
  (198, 3, 31, 8, 'cancelled', '11/27/2025', 'Nunc purus.'),
  (199, 19, 4, 3, 'cancelled', '1/29/2026', 'Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus. Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst. Maecenas ut massa quis augue luctus tincidunt.'),
  (200, 18, 90, 8, 'pending', '10/2/2025', 'Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem. Duis aliquam convallis nunc.');

-- =============================================================================
-- INSERT: Feedback (100 rows)
-- =============================================================================
INSERT INTO Feedback (feedback_id, user_id, event_id, rating, comment, submitted_at) VALUES
  (1, 15, 87, 4, 'Pellentesque ultrices mattis odio. Donec vitae nisi. Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus. Curabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla. Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam.', '11/23/2025'),
  (2, 14, 4, 2, 'Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem. Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus. Pellentesque at nulla.', '8/29/2025'),
  (3, 72, 50, 1, 'Nulla justo. Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros.', '10/28/2025'),
  (4, 91, 18, 5, 'Nulla tempus. Vivamus in felis eu sapien cursus vestibulum. Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem. Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit. Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi.', '12/10/2025'),
  (5, 7, 37, 1, 'In eleifend quam a odio. In hac habitasse platea dictumst. Maecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.', '7/20/2025'),
  (6, 17, 15, 5, 'Aenean auctor gravida sem. Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio. Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue.', '4/30/2026'),
  (7, 6, 50, 3, 'Aliquam sit amet diam in magna bibendum imperdiet.', '4/13/2026'),
  (8, 36, 63, 2, 'Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede. Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem. Fusce consequat. Nulla nisl. Nunc nisl.', '7/25/2025'),
  (9, 39, 9, 3, 'Fusce consequat. Nulla nisl. Nunc nisl.', '11/25/2025'),
  (10, 87, 79, 3, 'Sed ante. Vivamus tortor. Duis mattis egestas metus. Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.', '8/9/2025'),
  (11, 29, 79, 4, 'Aenean lectus. Pellentesque eget nunc.', '11/26/2025'),
  (12, 19, 51, 3, 'Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est.', '6/5/2025'),
  (13, 30, 54, 4, 'Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Etiam vel augue. Vestibulum rutrum rutrum neque.', '5/28/2025'),
  (14, 67, 94, 5, 'Morbi a ipsum. Integer a nibh.', '5/10/2026'),
  (15, 91, 23, 3, 'Fusce consequat. Nulla nisl. Nunc nisl.', '4/25/2026'),
  (16, 85, 5, 4, 'Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque. Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus. Phasellus in felis. Donec semper sapien a libero.', '4/11/2026'),
  (17, 42, 77, 5, 'Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis. Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem. Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus. Pellentesque at nulla. Suspendisse potenti.', '3/20/2026'),
  (18, 80, 29, 1, 'Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl. Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum. Curabitur in libero ut massa volutpat convallis.', '5/31/2025'),
  (19, 27, 22, 4, 'Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh. Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.', '2/20/2026'),
  (20, 84, 60, 1, 'Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus. Suspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst. Maecenas ut massa quis augue luctus tincidunt.', '8/20/2025'),
  (21, 86, 96, 4, 'Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo. Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis. Sed ante. Vivamus tortor.', '9/2/2025'),
  (22, 18, 28, 5, 'Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl. Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum. Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est. Phasellus sit amet erat. Nulla tempus.', '6/8/2025'),
  (23, 92, 72, 5, 'Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio. Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo.', '9/12/2025'),
  (24, 8, 72, 1, 'Vestibulum rutrum rutrum neque. Aenean auctor gravida sem. Praesent id massa id nisl venenatis lacinia.', '6/17/2025'),
  (25, 87, 78, 1, 'Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh. Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.', '12/30/2025'),
  (26, 73, 44, 1, 'Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Etiam vel augue. Vestibulum rutrum rutrum neque.', '3/20/2026'),
  (27, 21, 42, 3, 'Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui. Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti. Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris.', '8/12/2025'),
  (28, 83, 95, 2, 'Duis mattis egestas metus. Aenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh. Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros. Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.', '3/30/2026'),
  (29, 81, 1, 4, 'In eleifend quam a odio. In hac habitasse platea dictumst. Maecenas ut massa quis augue luctus tincidunt.', '11/15/2025'),
  (30, 98, 36, 5, 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio.', '6/18/2025'),
  (31, 73, 15, 3, 'In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo. Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis.', '10/8/2025'),
  (32, 10, 80, 1, 'Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue.', '6/7/2025'),
  (33, 97, 31, 4, 'Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque. Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus. Phasellus in felis.', '10/31/2025'),
  (34, 2, 34, 3, 'Vivamus vel nulla eget eros elementum pellentesque. Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus. Phasellus in felis. Donec semper sapien a libero. Nam dui. Proin leo odio, porttitor id, consequat in, consequat ut, nulla.', '12/13/2025'),
  (35, 83, 16, 1, 'Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin interdum mauris non ligula pellentesque ultrices.', '2/19/2026'),
  (36, 10, 56, 3, 'Nulla ac enim.', '8/26/2025'),
  (37, 21, 61, 1, 'Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis.', '1/13/2026'),
  (38, 98, 40, 2, 'Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris. Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis. Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem. Sed sagittis.', '4/27/2026'),
  (39, 42, 28, 4, 'Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis. Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.', '11/26/2025'),
  (40, 83, 59, 5, 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros. Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat. In congue.', '12/5/2025'),
  (41, 69, 7, 3, 'Ut at dolor quis odio consequat varius.', '12/9/2025'),
  (42, 52, 54, 2, 'Nunc rhoncus dui vel sem. Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus. Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.', '1/25/2026'),
  (43, 22, 74, 3, 'Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla.', '6/8/2025'),
  (44, 17, 72, 2, 'Vivamus in felis eu sapien cursus vestibulum. Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem. Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit. Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue.', '8/8/2025'),
  (45, 48, 51, 3, 'Aenean sit amet justo. Morbi ut odio. Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue.', '1/9/2026'),
  (46, 51, 89, 3, 'Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum. Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem. Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy.', '5/30/2025'),
  (47, 8, 56, 4, 'Maecenas pulvinar lobortis est. Phasellus sit amet erat. Nulla tempus.', '11/8/2025'),
  (48, 76, 83, 2, 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl. Aenean lectus. Pellentesque eget nunc.', '2/21/2026'),
  (49, 8, 18, 2, 'Nunc nisl. Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum. In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo. Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros.', '5/1/2026'),
  (50, 95, 100, 1, 'Nunc nisl. Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum. In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo. Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis.', '12/13/2025'),
  (51, 33, 53, 5, 'Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus.', '12/31/2025'),
  (52, 27, 100, 1, 'Donec dapibus. Duis at velit eu est congue elementum. In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.', '3/1/2026'),
  (53, 75, 34, 2, 'Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem. Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat.', '12/30/2025'),
  (54, 77, 91, 2, 'Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros. Vestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat. In congue. Etiam justo. Etiam pretium iaculis justo.', '10/19/2025'),
  (55, 32, 78, 4, 'Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi. Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque. Quisque porta volutpat erat.', '1/22/2026'),
  (56, 95, 58, 5, 'Aenean sit amet justo. Morbi ut odio. Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.', '4/8/2026'),
  (57, 92, 87, 1, 'Proin eu mi. Nulla ac enim.', '12/26/2025'),
  (58, 65, 4, 5, 'Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui. Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti. Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum.', '9/27/2025'),
  (59, 43, 21, 5, 'Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis. Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.', '3/4/2026'),
  (60, 73, 32, 2, 'Ut at dolor quis odio consequat varius. Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.', '5/5/2026'),
  (61, 42, 64, 3, 'Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque. Duis bibendum. Morbi non quam nec dui luctus rutrum.', '9/1/2025'),
  (62, 97, 60, 2, 'Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet. Maecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui. Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti. Nullam porttitor lacus at turpis.', '5/7/2026'),
  (63, 17, 83, 5, 'Pellentesque ultrices mattis odio. Donec vitae nisi. Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus. Curabitur at ipsum ac tellus semper interdum.', '4/30/2026'),
  (64, 55, 68, 3, 'Morbi non quam nec dui luctus rutrum.', '9/30/2025'),
  (65, 96, 8, 2, 'Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.', '3/17/2026'),
  (66, 94, 42, 2, 'Cras pellentesque volutpat dui. Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti. Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum.', '2/11/2026'),
  (67, 54, 30, 2, 'In congue. Etiam justo. Etiam pretium iaculis justo. In hac habitasse platea dictumst. Etiam faucibus cursus urna.', '3/31/2026'),
  (68, 64, 58, 2, 'Nulla tempus. Vivamus in felis eu sapien cursus vestibulum. Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem. Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit.', '6/24/2025'),
  (69, 67, 44, 4, 'Nunc nisl. Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.', '6/12/2025'),
  (70, 88, 75, 3, 'Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem. Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus. Pellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.', '1/18/2026'),
  (71, 30, 81, 5, 'Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem. Duis aliquam convallis nunc.', '4/28/2026'),
  (72, 58, 70, 3, 'Nam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus. Curabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla. Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam.', '2/1/2026'),
  (73, 50, 88, 2, 'Integer non velit. Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque. Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.', '2/8/2026'),
  (74, 55, 49, 3, 'Donec dapibus. Duis at velit eu est congue elementum. In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.', '8/18/2025'),
  (75, 8, 81, 2, 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit.', '4/1/2026'),
  (76, 2, 79, 1, 'Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit.', '9/2/2025'),
  (77, 70, 12, 2, 'Cras in purus eu magna vulputate luctus.', '11/6/2025'),
  (78, 62, 91, 2, 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti. Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris. Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis. Fusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl.', '2/27/2026'),
  (79, 93, 96, 4, 'Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Etiam vel augue. Vestibulum rutrum rutrum neque.', '7/19/2025'),
  (80, 47, 61, 5, 'Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus. Phasellus in felis. Donec semper sapien a libero. Nam dui. Proin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.', '3/14/2026'),
  (81, 44, 42, 1, 'Duis consequat dui nec nisi volutpat eleifend.', '7/8/2025'),
  (82, 79, 61, 2, 'Sed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus. Pellentesque at nulla.', '9/13/2025'),
  (83, 39, 19, 4, 'Quisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est.', '4/12/2026'),
  (84, 35, 35, 2, 'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti. Nullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris. Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.', '4/4/2026'),
  (85, 19, 41, 5, 'Quisque ut erat. Curabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem. Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat. Praesent blandit.', '9/11/2025'),
  (86, 61, 21, 4, 'Curabitur in libero ut massa volutpat convallis.', '12/16/2025'),
  (87, 27, 68, 3, 'Integer non velit. Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque. Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.', '4/3/2026'),
  (88, 6, 11, 5, 'Etiam justo. Etiam pretium iaculis justo. In hac habitasse platea dictumst.', '2/15/2026'),
  (89, 33, 32, 5, 'Suspendisse potenti. Cras in purus eu magna vulputate luctus. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem. Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo.', '12/16/2025'),
  (90, 52, 31, 3, 'Nulla nisl. Nunc nisl. Duis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum. In hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo. Aliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros.', '2/28/2026'),
  (91, 76, 77, 1, 'Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est. Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.', '6/7/2025'),
  (92, 2, 79, 5, 'Nulla facilisi. Cras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque. Quisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus. Phasellus in felis.', '4/8/2026'),
  (93, 59, 37, 3, 'Proin at turpis a pede posuere nonummy. Integer non velit. Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque. Duis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.', '11/1/2025'),
  (94, 57, 97, 3, 'Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl.', '10/20/2025'),
  (95, 97, 36, 4, 'Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis. Fusce posuere felis sed lacus.', '8/28/2025'),
  (96, 84, 61, 1, 'Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat. In congue. Etiam justo. Etiam pretium iaculis justo. In hac habitasse platea dictumst. Etiam faucibus cursus urna.', '5/7/2026'),
  (97, 17, 21, 3, 'Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio. Cras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim.', '5/1/2026'),
  (98, 71, 85, 1, 'Vivamus in felis eu sapien cursus vestibulum. Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem. Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit. Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.', '5/23/2025'),
  (99, 96, 15, 4, 'Quisque porta volutpat erat.', '3/11/2026'),
  (100, 35, 20, 3, 'Quisque id justo sit amet sapien dignissim vestibulum.', '4/12/2026');

-- =============================================================================
-- UPDATE OPERATIONS (with WHERE conditions)
-- =============================================================================

-- UPDATE 1: Confirm all pending bookings that were made before 2026
UPDATE Bookings
SET    booking_status = 'confirmed'
WHERE  booking_status = 'pending'
  AND  booking_date   < '2026-01-01';

-- UPDATE 2: Mark events whose event_date has already passed as 'completed'
UPDATE Events
SET    status = 'completed'
WHERE  status   = 'upcoming'
  AND  event_date < CURDATE();

-- UPDATE 3: Standardise user role — rename legacy 'customer' role to 'user'
UPDATE Users
SET    role = 'user'
WHERE  role = 'customer';


-- =============================================================================
-- DELETE OPERATIONS (with WHERE conditions)
-- =============================================================================

-- DELETE 1: Remove cancelled bookings older than one year
DELETE FROM Bookings
WHERE  booking_status = 'cancelled'
  AND  booking_date   < DATE_SUB(CURDATE(), INTERVAL 1 YEAR);

-- DELETE 2: Remove feedback with a NULL or empty comment (data-quality purge)
DELETE FROM Feedback
WHERE  comment IS NULL
   OR  TRIM(comment) = '';


-- =============================================================================
-- VALIDATION QUERIES
-- =============================================================================

-- ----------------------------------------------------------------------------
-- 1. ROW COUNTS — confirm data was loaded
-- ----------------------------------------------------------------------------
SELECT 'Categories' AS table_name, COUNT(*) AS row_count FROM Categories
UNION ALL
SELECT 'Organizers',               COUNT(*)               FROM Organizers
UNION ALL
SELECT 'Users',                    COUNT(*)               FROM Users
UNION ALL
SELECT 'Events',                   COUNT(*)               FROM Events
UNION ALL
SELECT 'Bookings',                 COUNT(*)               FROM Bookings
UNION ALL
SELECT 'Feedback',                 COUNT(*)               FROM Feedback;

-- ----------------------------------------------------------------------------
-- 2. NULL CHECKS on key columns
-- ----------------------------------------------------------------------------

-- Users: critical columns
SELECT 'Users - NULL name'     AS check_name, COUNT(*) AS null_count FROM Users WHERE name     IS NULL
UNION ALL
SELECT 'Users - NULL email',                  COUNT(*)               FROM Users WHERE email    IS NULL
UNION ALL
SELECT 'Users - NULL role',                   COUNT(*)               FROM Users WHERE role     IS NULL
UNION ALL
-- Events: critical columns
SELECT 'Events - NULL event_name',            COUNT(*)               FROM Events WHERE event_name IS NULL
UNION ALL
SELECT 'Events - NULL event_date',            COUNT(*)               FROM Events WHERE event_date IS NULL
UNION ALL
SELECT 'Events - NULL category_id',           COUNT(*)               FROM Events WHERE category_id IS NULL
UNION ALL
SELECT 'Events - NULL organizer_id',          COUNT(*)               FROM Events WHERE organizer_id IS NULL
UNION ALL
-- Bookings: critical columns
SELECT 'Bookings - NULL user_id',             COUNT(*)               FROM Bookings WHERE user_id  IS NULL
UNION ALL
SELECT 'Bookings - NULL event_id',            COUNT(*)               FROM Bookings WHERE event_id IS NULL
UNION ALL
SELECT 'Bookings - NULL booking_status',      COUNT(*)               FROM Bookings WHERE booking_status IS NULL
UNION ALL
-- Feedback: critical columns
SELECT 'Feedback - NULL user_id',             COUNT(*)               FROM Feedback WHERE user_id  IS NULL
UNION ALL
SELECT 'Feedback - NULL event_id',            COUNT(*)               FROM Feedback WHERE event_id IS NULL
UNION ALL
SELECT 'Feedback - NULL rating',              COUNT(*)               FROM Feedback WHERE rating   IS NULL;

-- ----------------------------------------------------------------------------
-- 3. FOREIGN KEY INTEGRITY CHECKS (JOIN-based)
-- ----------------------------------------------------------------------------

-- 3a. Events → Categories: every event must have a valid category
SELECT 'Events with invalid category_id' AS fk_check,
       COUNT(*) AS orphan_count
FROM   Events e
LEFT JOIN Categories c ON e.category_id = c.category_id
WHERE  c.category_id IS NULL;

-- 3b. Events → Organizers: every event must have a valid organizer
SELECT 'Events with invalid organizer_id' AS fk_check,
       COUNT(*) AS orphan_count
FROM   Events e
LEFT JOIN Organizers o ON e.organizer_id = o.organizer_id
WHERE  o.organizer_id IS NULL;

-- 3c. Bookings → Users: every booking must reference a real user
SELECT 'Bookings with invalid user_id' AS fk_check,
       COUNT(*) AS orphan_count
FROM   Bookings b
LEFT JOIN Users u ON b.user_id = u.user_id
WHERE  u.user_id IS NULL;

-- 3d. Bookings → Events: every booking must reference a real event
SELECT 'Bookings with invalid event_id' AS fk_check,
       COUNT(*) AS orphan_count
FROM   Bookings b
LEFT JOIN Events e ON b.event_id = e.event_id
WHERE  e.event_id IS NULL;

-- 3e. Feedback → Users: every feedback row must reference a real user
SELECT 'Feedback with invalid user_id' AS fk_check,
       COUNT(*) AS orphan_count
FROM   Feedback f
LEFT JOIN Users u ON f.user_id = u.user_id
WHERE  u.user_id IS NULL;

-- 3f. Feedback → Events: every feedback row must reference a real event
SELECT 'Feedback with invalid event_id' AS fk_check,
       COUNT(*) AS orphan_count
FROM   Feedback f
LEFT JOIN Events e ON f.event_id = e.event_id
WHERE  e.event_id IS NULL;

-- ----------------------------------------------------------------------------
-- 4. SAMPLE CROSS-TABLE JOIN — sanity check on real data
-- ----------------------------------------------------------------------------

-- Show 10 bookings with user name, event name, and booking status
SELECT b.booking_id,
       u.name            AS user_name,
       e.event_name,
       b.seats_booked,
       b.booking_status,
       b.booking_date
FROM   Bookings b
JOIN   Users  u ON b.user_id  = u.user_id
JOIN   Events e ON b.event_id = e.event_id
ORDER  BY b.booking_id
LIMIT  10;

-- Show average rating per event (top 10)
SELECT e.event_id,
       e.event_name,
       ROUND(AVG(f.rating), 2) AS avg_rating,
       COUNT(f.feedback_id)    AS total_reviews
FROM   Events   e
JOIN   Feedback f ON e.event_id = f.event_id
GROUP  BY e.event_id, e.event_name
ORDER  BY avg_rating DESC
LIMIT  10;

SET FOREIGN_KEY_CHECKS = 1;

-- =============================================================================
-- END OF SCRIPT
-- =============================================================================
