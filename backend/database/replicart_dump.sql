--
-- PostgreSQL database dump
--

-- Dumped from database version 12.4
-- Dumped by pg_dump version 12.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

DROP DATABASE replicart;
--
-- Name: replicart; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE replicart WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'English_United States.1252' LC_CTYPE = 'English_United States.1252';


ALTER DATABASE replicart OWNER TO postgres;

\connect replicart

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: account; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.account (
    id integer NOT NULL,
    username text NOT NULL,
    password text NOT NULL,
    role_id integer NOT NULL
);


ALTER TABLE public.account OWNER TO postgres;

--
-- Name: account_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.account_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.account_id_seq OWNER TO postgres;

--
-- Name: account_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.account_id_seq OWNED BY public.account.id;


--
-- Name: basket_item; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.basket_item (
    replica_id integer NOT NULL,
    account_id integer NOT NULL,
    quantity integer NOT NULL
);


ALTER TABLE public.basket_item OWNER TO postgres;

--
-- Name: order; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."order" (
    id integer NOT NULL,
    account_id integer NOT NULL
);


ALTER TABLE public."order" OWNER TO postgres;

--
-- Name: order_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.order_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.order_id_seq OWNER TO postgres;

--
-- Name: order_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.order_id_seq OWNED BY public."order".id;


--
-- Name: order_item; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_item (
    quantity integer NOT NULL,
    order_id integer NOT NULL,
    replica_id integer NOT NULL
);


ALTER TABLE public.order_item OWNER TO postgres;

--
-- Name: replica; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.replica (
    id integer NOT NULL,
    artist text NOT NULL,
    name text NOT NULL,
    origin text NOT NULL,
    cost numeric(8,2) NOT NULL,
    image_url text,
    year numeric(4,0) NOT NULL
);


ALTER TABLE public.replica OWNER TO postgres;

--
-- Name: replica_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.replica_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.replica_id_seq OWNER TO postgres;

--
-- Name: replica_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.replica_id_seq OWNED BY public.replica.id;


--
-- Name: role; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.role (
    id integer NOT NULL,
    name text NOT NULL
);


ALTER TABLE public.role OWNER TO postgres;

--
-- Name: role_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.role_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.role_id_seq OWNER TO postgres;

--
-- Name: role_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.role_id_seq OWNED BY public.role.id;


--
-- Name: account id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account ALTER COLUMN id SET DEFAULT nextval('public.account_id_seq'::regclass);


--
-- Name: order id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."order" ALTER COLUMN id SET DEFAULT nextval('public.order_id_seq'::regclass);


--
-- Name: replica id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.replica ALTER COLUMN id SET DEFAULT nextval('public.replica_id_seq'::regclass);


--
-- Name: role id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role ALTER COLUMN id SET DEFAULT nextval('public.role_id_seq'::regclass);


--
-- Data for Name: account; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.account (id, username, password, role_id) VALUES (1, 'Ajob', '$2b$12$VnGKurmhsQ11yFi/vpV7E.igpwQ2V6SZgRnwr3kY2/.WB1MtEr6J.', 1);
INSERT INTO public.account (id, username, password, role_id) VALUES (2, 'Danique', '$2b$12$z.Y5tVQe3ixFdNRMNEh/puH8WmQMNDxIzwMJkyavMKTlOz..zEGgq', 1);
INSERT INTO public.account (id, username, password, role_id) VALUES (3, 'Sander', '$2b$12$7kqwt2qkWUGRk7ll.X5xO.J5zbgqvJurpPekuxzp7hZUqA7H8JlJC', 1);
INSERT INTO public.account (id, username, password, role_id) VALUES (4, 'admin', '$2b$12$kJFZESm82a3FXxURDNVc6uiu3u98L.uLx5RZS3J5L8pSgPVuTJuPq', 2);
INSERT INTO public.account (id, username, password, role_id) VALUES (13, 'hoola', '$2b$12$u7nwTGjOYmkJ9WKF3ktye.7/FlabGtIfS7WORZQj2aBQx7ipYl55y', 1);
INSERT INTO public.account (id, username, password, role_id) VALUES (15, 'Dani', '$2b$12$gpuX2.pWGf7mArB3cL2dBOlX5YF7hPRyOpVms5lmzIQ9ZstqlR35W', 1);
INSERT INTO public.account (id, username, password, role_id) VALUES (16, 'Lob', '$2b$12$VvfjcQG4Xznm4NHVEA3Cz.qb41UKB/t6i4fvBcOgv2szjSq4MhJ5q', 1);
INSERT INTO public.account (id, username, password, role_id) VALUES (17, 'JohnDoe', '$2b$12$4ncF3CQkcCUJ4SqVbETR0.nFVj/E83fkRN1f.OvPnxHnG1K1916my', 1);
INSERT INTO public.account (id, username, password, role_id) VALUES (18, 'Jake', '$2b$12$qvu76GuzEVQO1fwj7Ty46umNanGjc4GNBB57b9tBLU.S4Zf01jvJC', 1);
INSERT INTO public.account (id, username, password, role_id) VALUES (19, 'koolkid', '$2b$12$YTUD9bksqg7CWyQgSig4nuG1ZsH0m5kRtp3mhlpJcrLOJLwxJEM3W', 1);
INSERT INTO public.account (id, username, password, role_id) VALUES (20, 'testboi', '$2b$12$VJ70VmddVc63RGpVgEKU2.JtUoJTRu8oGmLAEUi.i1JeNnE7afa7y', 1);
INSERT INTO public.account (id, username, password, role_id) VALUES (21, 'heyo', '$2b$12$pklnbfRUvpBD7ZHlBI9oZew4UAs3SLtR8vtkSm35q8mIDWSFlEgiO', 1);
INSERT INTO public.account (id, username, password, role_id) VALUES (22, 'Armin', '$2b$12$YspJDylPY4VK.l9ybmbsmeXhH1.93//N2E29QL4u4D.V1D1dqlmi.', 1);
INSERT INTO public.account (id, username, password, role_id) VALUES (23, 'hellohello', '$2b$12$hfTidBmeFsWSUamO.DI4XOB.Fh5Qgr4ILzz0DD9tEhAsjnVId1khy', 1);
INSERT INTO public.account (id, username, password, role_id) VALUES (24, 'heyoyo', '$2b$12$Ci4kZvCQEqiBePE8mXmOieR4x/bAwOdLf3hGHXY6.U4czQV2k81G6', 1);
INSERT INTO public.account (id, username, password, role_id) VALUES (25, 'jooooop', '$2b$12$ZR.cVCMewxUFPIF0zec6PuSJdeoY9VV5h0yRHF2nB9AG5yCcyUUqm', 1);
INSERT INTO public.account (id, username, password, role_id) VALUES (27, 'jooooopx', '$2b$12$SzzHoh9jSUuxohWbgisAletxz0TpTeKAcJhXIxM5UsUxcsaoQsqei', 1);
INSERT INTO public.account (id, username, password, role_id) VALUES (28, 'Wazaaaa', '$2b$12$RotiUKumXJmDbLMppbuZ..PFFH2I7kfhqm3dqm9SabXyOBDdB/9lW', 1);
INSERT INTO public.account (id, username, password, role_id) VALUES (29, 'Winter', '$2b$12$h2A97hUZq06tdOd6nFwNa..FzaU1LG1IKZoxQzv0iMEP4xZpC3YLq', 1);
INSERT INTO public.account (id, username, password, role_id) VALUES (30, 'Pop', '$2b$12$0yRqr3zViyRLxEsNHpZ.R.lQ5CBLRjK.K0UZCMR6o3m2LJBxYV69y', 1);


--
-- Data for Name: basket_item; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.basket_item (replica_id, account_id, quantity) VALUES (21, 1, 3);
INSERT INTO public.basket_item (replica_id, account_id, quantity) VALUES (2, 1, 3);
INSERT INTO public.basket_item (replica_id, account_id, quantity) VALUES (1, 1, 1);


--
-- Data for Name: order; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."order" (id, account_id) VALUES (17, 2);
INSERT INTO public."order" (id, account_id) VALUES (18, 2);
INSERT INTO public."order" (id, account_id) VALUES (19, 2);
INSERT INTO public."order" (id, account_id) VALUES (20, 1);
INSERT INTO public."order" (id, account_id) VALUES (21, 1);
INSERT INTO public."order" (id, account_id) VALUES (22, 1);
INSERT INTO public."order" (id, account_id) VALUES (23, 1);
INSERT INTO public."order" (id, account_id) VALUES (24, 1);
INSERT INTO public."order" (id, account_id) VALUES (25, 1);
INSERT INTO public."order" (id, account_id) VALUES (26, 3);
INSERT INTO public."order" (id, account_id) VALUES (27, 3);
INSERT INTO public."order" (id, account_id) VALUES (28, 1);
INSERT INTO public."order" (id, account_id) VALUES (29, 1);
INSERT INTO public."order" (id, account_id) VALUES (30, 2);
INSERT INTO public."order" (id, account_id) VALUES (31, 2);
INSERT INTO public."order" (id, account_id) VALUES (32, 2);
INSERT INTO public."order" (id, account_id) VALUES (33, 1);
INSERT INTO public."order" (id, account_id) VALUES (34, 2);
INSERT INTO public."order" (id, account_id) VALUES (35, 13);
INSERT INTO public."order" (id, account_id) VALUES (36, 1);
INSERT INTO public."order" (id, account_id) VALUES (37, 1);
INSERT INTO public."order" (id, account_id) VALUES (38, 1);
INSERT INTO public."order" (id, account_id) VALUES (39, 15);
INSERT INTO public."order" (id, account_id) VALUES (40, 2);
INSERT INTO public."order" (id, account_id) VALUES (41, 16);
INSERT INTO public."order" (id, account_id) VALUES (42, 16);
INSERT INTO public."order" (id, account_id) VALUES (43, 18);
INSERT INTO public."order" (id, account_id) VALUES (44, 18);
INSERT INTO public."order" (id, account_id) VALUES (45, 18);
INSERT INTO public."order" (id, account_id) VALUES (46, 18);
INSERT INTO public."order" (id, account_id) VALUES (47, 29);
INSERT INTO public."order" (id, account_id) VALUES (48, 2);
INSERT INTO public."order" (id, account_id) VALUES (49, 30);


--
-- Data for Name: order_item; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.order_item (quantity, order_id, replica_id) VALUES (1, 17, 23);
INSERT INTO public.order_item (quantity, order_id, replica_id) VALUES (1, 17, 21);
INSERT INTO public.order_item (quantity, order_id, replica_id) VALUES (1, 17, 20);
INSERT INTO public.order_item (quantity, order_id, replica_id) VALUES (1, 17, 16);
INSERT INTO public.order_item (quantity, order_id, replica_id) VALUES (1, 18, 11);
INSERT INTO public.order_item (quantity, order_id, replica_id) VALUES (1, 18, 12);
INSERT INTO public.order_item (quantity, order_id, replica_id) VALUES (2, 18, 13);
INSERT INTO public.order_item (quantity, order_id, replica_id) VALUES (1, 18, 15);
INSERT INTO public.order_item (quantity, order_id, replica_id) VALUES (1, 19, 2);
INSERT INTO public.order_item (quantity, order_id, replica_id) VALUES (10, 20, 2);
INSERT INTO public.order_item (quantity, order_id, replica_id) VALUES (2, 20, 21);
INSERT INTO public.order_item (quantity, order_id, replica_id) VALUES (4, 21, 2);
INSERT INTO public.order_item (quantity, order_id, replica_id) VALUES (3, 21, 11);
INSERT INTO public.order_item (quantity, order_id, replica_id) VALUES (1, 21, 12);
INSERT INTO public.order_item (quantity, order_id, replica_id) VALUES (4, 22, 11);
INSERT INTO public.order_item (quantity, order_id, replica_id) VALUES (1, 22, 2);
INSERT INTO public.order_item (quantity, order_id, replica_id) VALUES (7, 22, 12);
INSERT INTO public.order_item (quantity, order_id, replica_id) VALUES (12, 22, 1);
INSERT INTO public.order_item (quantity, order_id, replica_id) VALUES (2, 22, 13);
INSERT INTO public.order_item (quantity, order_id, replica_id) VALUES (4, 23, 2);
INSERT INTO public.order_item (quantity, order_id, replica_id) VALUES (2, 24, 1);
INSERT INTO public.order_item (quantity, order_id, replica_id) VALUES (1, 24, 19);
INSERT INTO public.order_item (quantity, order_id, replica_id) VALUES (3, 24, 16);
INSERT INTO public.order_item (quantity, order_id, replica_id) VALUES (4, 25, 1);
INSERT INTO public.order_item (quantity, order_id, replica_id) VALUES (30, 26, 13);
INSERT INTO public.order_item (quantity, order_id, replica_id) VALUES (2, 27, 2);
INSERT INTO public.order_item (quantity, order_id, replica_id) VALUES (2, 27, 11);
INSERT INTO public.order_item (quantity, order_id, replica_id) VALUES (3, 27, 12);
INSERT INTO public.order_item (quantity, order_id, replica_id) VALUES (1, 28, 14);
INSERT INTO public.order_item (quantity, order_id, replica_id) VALUES (4, 29, 17);
INSERT INTO public.order_item (quantity, order_id, replica_id) VALUES (10, 29, 2);
INSERT INTO public.order_item (quantity, order_id, replica_id) VALUES (4, 29, 19);
INSERT INTO public.order_item (quantity, order_id, replica_id) VALUES (2, 29, 18);
INSERT INTO public.order_item (quantity, order_id, replica_id) VALUES (1, 30, 1);
INSERT INTO public.order_item (quantity, order_id, replica_id) VALUES (3, 32, 2);
INSERT INTO public.order_item (quantity, order_id, replica_id) VALUES (1, 33, 12);
INSERT INTO public.order_item (quantity, order_id, replica_id) VALUES (1, 33, 22);
INSERT INTO public.order_item (quantity, order_id, replica_id) VALUES (2, 35, 21);
INSERT INTO public.order_item (quantity, order_id, replica_id) VALUES (1, 35, 2);
INSERT INTO public.order_item (quantity, order_id, replica_id) VALUES (6, 36, 13);
INSERT INTO public.order_item (quantity, order_id, replica_id) VALUES (6, 37, 13);
INSERT INTO public.order_item (quantity, order_id, replica_id) VALUES (6, 38, 13);
INSERT INTO public.order_item (quantity, order_id, replica_id) VALUES (1, 39, 21);
INSERT INTO public.order_item (quantity, order_id, replica_id) VALUES (1, 39, 19);
INSERT INTO public.order_item (quantity, order_id, replica_id) VALUES (1, 40, 21);
INSERT INTO public.order_item (quantity, order_id, replica_id) VALUES (1, 41, 21);
INSERT INTO public.order_item (quantity, order_id, replica_id) VALUES (1, 41, 20);
INSERT INTO public.order_item (quantity, order_id, replica_id) VALUES (3, 42, 21);
INSERT INTO public.order_item (quantity, order_id, replica_id) VALUES (3, 43, 21);
INSERT INTO public.order_item (quantity, order_id, replica_id) VALUES (1, 43, 2);
INSERT INTO public.order_item (quantity, order_id, replica_id) VALUES (2, 44, 2);
INSERT INTO public.order_item (quantity, order_id, replica_id) VALUES (2, 44, 21);
INSERT INTO public.order_item (quantity, order_id, replica_id) VALUES (1, 44, 13);
INSERT INTO public.order_item (quantity, order_id, replica_id) VALUES (3, 45, 2);
INSERT INTO public.order_item (quantity, order_id, replica_id) VALUES (3, 45, 1);
INSERT INTO public.order_item (quantity, order_id, replica_id) VALUES (2, 46, 2);
INSERT INTO public.order_item (quantity, order_id, replica_id) VALUES (1, 47, 17);
INSERT INTO public.order_item (quantity, order_id, replica_id) VALUES (1, 47, 18);
INSERT INTO public.order_item (quantity, order_id, replica_id) VALUES (1, 47, 20);
INSERT INTO public.order_item (quantity, order_id, replica_id) VALUES (1, 48, 21);
INSERT INTO public.order_item (quantity, order_id, replica_id) VALUES (30, 49, 23);
INSERT INTO public.order_item (quantity, order_id, replica_id) VALUES (30, 49, 17);
INSERT INTO public.order_item (quantity, order_id, replica_id) VALUES (30, 49, 2);
INSERT INTO public.order_item (quantity, order_id, replica_id) VALUES (30, 49, 21);
INSERT INTO public.order_item (quantity, order_id, replica_id) VALUES (30, 49, 14);
INSERT INTO public.order_item (quantity, order_id, replica_id) VALUES (30, 49, 22);
INSERT INTO public.order_item (quantity, order_id, replica_id) VALUES (30, 49, 15);


--
-- Data for Name: replica; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.replica (id, artist, name, origin, cost, image_url, year) VALUES (2, 'Johannes Vermeer', 'Girl with a Pearl Earring', 'Netherlands', 940.00, 'https://i.imgur.com/sSM9iFa.png', 1665);
INSERT INTO public.replica (id, artist, name, origin, cost, image_url, year) VALUES (11, 'Laurits Andersen Ring', 'The Artist''s Wife', 'Denmark', 530.00, 'https://az333960.vo.msecnd.net/images-9/the-artist-s-wife-laurits-andersen-ring-1897-302882b2.jpg', 1897);
INSERT INTO public.replica (id, artist, name, origin, cost, image_url, year) VALUES (12, 'Christoffer Wilhelm Eckersberg', 'Ships in the Sound North of Kronborg Castle, Elsinore', 'Denmark', 740.00, 'https://az333960.vo.msecnd.net/images-7/ships-in-the-sound-north-of-kronborg-castle-elsinore-christoffer-wilhelm-eckersberg-1847-23066315.jpg', 1847);
INSERT INTO public.replica (id, artist, name, origin, cost, image_url, year) VALUES (13, 'Frank Weston Benson', 'Margaret (Gretchen) Strong', 'United States', 290.00, 'https://az334033.vo.msecnd.net/images-5/margaret-gretchen-strong-frank-weston-benson-7b373195.jpg', 1909);
INSERT INTO public.replica (id, artist, name, origin, cost, image_url, year) VALUES (15, 'Ubaldo Gandolfi', 'Selene and Endymion', 'Italy', 840.00, 'https://az333959.vo.msecnd.net/images-8/selene-and-endymion-ubaldo-gandolfi-dacd377e.jpg', 1770);
INSERT INTO public.replica (id, artist, name, origin, cost, image_url, year) VALUES (17, 'Johannes Vermeer', 'The Milkmaid', 'Netherlands', 505.00, 'https://az334034.vo.msecnd.net/images-9/the-milkmaid-johannes-vermeer-1658-0f5403a4.jpg', 1660);
INSERT INTO public.replica (id, artist, name, origin, cost, image_url, year) VALUES (18, 'Jean-Baptiste-Siméon Chardin', 'Soap Bubbles', 'France', 690.00, 'https://az334033.vo.msecnd.net/images-1/soap-bubbles-jean-baptiste-simeon-chardin-1-0e295b5a.jpg', 1739);
INSERT INTO public.replica (id, artist, name, origin, cost, image_url, year) VALUES (19, 'Jan Asselijn', 'The Threatened Swan', 'Netherlands', 900.00, 'https://az333959.vo.msecnd.net/images-9/the-threatened-swan-jan-asselijn-1650-49726826.jpg', 1650);
INSERT INTO public.replica (id, artist, name, origin, cost, image_url, year) VALUES (20, 'Katrina Taivane', 'Kite', 'Latvia', 730.00, 'https://az333960.vo.msecnd.net/images-1/kite-katrina-taivane-2012-972f1175.jpg', 2012);
INSERT INTO public.replica (id, artist, name, origin, cost, image_url, year) VALUES (22, 'Frank Weston Benson', 'Sunlight', 'United States', 910.00, 'https://az333960.vo.msecnd.net/images-2/sunlight-frank-w-benson-1909-57ddb5d9.jpg', 1909);
INSERT INTO public.replica (id, artist, name, origin, cost, image_url, year) VALUES (23, 'Olivier Lamboray', 'The Playing Room', 'Belgium', 360.00, 'https://az334033.vo.msecnd.net/images-9/the-playing-room-olamboray-2012-5ebccac1.jpg', 2012);
INSERT INTO public.replica (id, artist, name, origin, cost, image_url, year) VALUES (14, 'Jean-Auguste-Dominique Ingres', 'Ulysses', 'France', 990.00, 'https://az334034.vo.msecnd.net/images-9/ulysses-jean-auguste-dominique-ingres-1827-46b65828.jpg', 1827);
INSERT INTO public.replica (id, artist, name, origin, cost, image_url, year) VALUES (16, 'Pierre Joseph Toussaint', 'The Young Painter', 'Belgium', 460.00, 'https://az334034.vo.msecnd.net/images-1/de-jonge-schilder-pierre-joseph-toussaint-1850-838d37a0.jpg', 1850);
INSERT INTO public.replica (id, artist, name, origin, cost, image_url, year) VALUES (21, 'Andrey Aranyshev', 'Dance', 'Russia', 1250.00, 'https://az334033.vo.msecnd.net/images-1/dance-andrey-aranyshev-2001-989d8ee9.jpg', 2001);
INSERT INTO public.replica (id, artist, name, origin, cost, image_url, year) VALUES (1, 'William-Adolphe Bougereau', 'A Young Girl Defending Herself against Eros', 'France', 680.00, 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/22/A_Girl_Defending_Herself_against_Eros%2C_by_William-Adolphe_Bouguereau.jpg/1200px-A_Girl_Defending_Herself_against_Eros%2C_by_William-Adolphe_Bouguereau.jpg', 1880);


--
-- Data for Name: role; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.role (id, name) VALUES (1, 'Customer');
INSERT INTO public.role (id, name) VALUES (2, 'Administrator');


--
-- Name: account_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.account_id_seq', 30, true);


--
-- Name: order_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.order_id_seq', 49, true);


--
-- Name: replica_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.replica_id_seq', 69, true);


--
-- Name: role_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.role_id_seq', 2, true);


--
-- Name: account account_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account
    ADD CONSTRAINT account_pkey PRIMARY KEY (id);


--
-- Name: basket_item basket_item_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.basket_item
    ADD CONSTRAINT basket_item_pk PRIMARY KEY (replica_id, account_id);


--
-- Name: order_item order_item_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_item
    ADD CONSTRAINT order_item_pkey PRIMARY KEY (order_id, replica_id);


--
-- Name: order order_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."order"
    ADD CONSTRAINT order_pkey PRIMARY KEY (id);


--
-- Name: replica replica_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.replica
    ADD CONSTRAINT replica_pkey PRIMARY KEY (id);


--
-- Name: role role_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role
    ADD CONSTRAINT role_pkey PRIMARY KEY (id);


--
-- Name: account unique_username; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account
    ADD CONSTRAINT unique_username UNIQUE (username);


--
-- Name: order account_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."order"
    ADD CONSTRAINT account_id_fk FOREIGN KEY (account_id) REFERENCES public.account(id);


--
-- Name: basket_item fk_account_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.basket_item
    ADD CONSTRAINT fk_account_id FOREIGN KEY (account_id) REFERENCES public.account(id) ON DELETE CASCADE;


--
-- Name: basket_item fk_replica_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.basket_item
    ADD CONSTRAINT fk_replica_id FOREIGN KEY (replica_id) REFERENCES public.replica(id) ON DELETE CASCADE;


--
-- Name: order_item order_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_item
    ADD CONSTRAINT order_id_fk FOREIGN KEY (order_id) REFERENCES public."order"(id);


--
-- Name: order_item replica_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_item
    ADD CONSTRAINT replica_id_fk FOREIGN KEY (replica_id) REFERENCES public.replica(id) ON DELETE CASCADE;


--
-- Name: account role_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account
    ADD CONSTRAINT role_id_fk FOREIGN KEY (role_id) REFERENCES public.role(id);


--
-- PostgreSQL database dump complete
--

