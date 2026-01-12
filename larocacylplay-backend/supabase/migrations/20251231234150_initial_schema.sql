-- Tabla para revenuecat events --


CREATE TYPE profile_role AS ENUM ('admin', 'suscriber', 'member');
CREATE TABLE profiles (
    user_id uuid PRIMARY KEY REFERENCES auth.users(id) on DELETE CASCADE,
    display_name TEXT,
    email TEXT,
    avatar_url TEXT,
    avatar_id TEXT,
    locale TEXT DEFAULT 'es',
    profile_role profile_role default 'member',
    created_at timestamptz default now(),
    updated_at timestamptz default now()
);
CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM profiles p
        WHERE p.user_id = auth.uid()
        AND p.profile_role = 'admin'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Read own profile" ON profiles FOR SELECT TO authenticated USING (auth.uid() = user_id);
CREATE POLICY "Admins can read all profiles" ON profiles FOR SELECT TO authenticated USING (is_admin());
CREATE POLICY "Update own profile" ON profiles FOR UPDATE TO authenticated USING (auth.uid() = user_id);
CREATE POLICY "Admins can update all profiles" ON profiles FOR UPDATE TO authenticated USING (is_admin());

CREATE TABLE IF NOT EXISTS revenuecat_event (
  id BIGSERIAL PRIMARY KEY,
  event_id TEXT NOT NULL UNIQUE, -- ID único del evento de RevenueCat
  event_type TEXT NOT NULL, -- Tipo de evento: INITIAL_PURCHASE, RENEWAL, CANCELLATION, etc.
  app_user_id UUID NOT NULL, -- RevenueCat app_user_id (UUID del usuario)
  payload JSONB NOT NULL, -- Payload completo del evento para referencia
  created_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT fk_user_id FOREIGN KEY (app_user_id) REFERENCES profiles(user_id) ON DELETE NO ACTION
);

CREATE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
as $$
BEGIN
-- Verificamos que tenga email y que NO sea anónimo
  IF NEW.email IS NOT NULL AND (NEW.raw_app_meta_data->>'is_anonymous')::boolean IS DISTINCT FROM true THEN
    
    INSERT INTO public.profiles (user_id, email)
    VALUES (NEW.id, NEW.email)
    ON CONFLICT (user_id) DO UPDATE
    SET 
      email = EXCLUDED.email,
      updated_at = NOW();
      
  END IF;
  
  RETURN NEW;
END;
$$;
-- CREATE TRIGGER on_auth_user_created
-- AFTER INSERT ON auth.users
-- FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();
CREATE TRIGGER on_auth_user_created_or_updated
AFTER INSERT OR UPDATE OF email, raw_app_meta_data ON auth.users
FOR EACH ROW
EXECUTE PROCEDURE public.handle_new_user();


create table subscription (
  id bigserial primary key,

  -- Usuario en tu sistema
  user_id uuid not null
    references public.profiles(user_id)
    on delete cascade,

  -- RevenueCat (identidad)
  rc_app_user_id text not null,
  rc_entitlement_id text not null,      -- ej: "pro"
  rc_product_id text not null,          -- ej: "rc_4999_1y_1w0"
  rc_product_display_name text not null,
  rc_store text not null,               -- app_store / play_store / test_store

  -- Tipo de plan (derivado del product_id)
  plan_type text not null
    check (plan_type in ('normal', 'intro', 'trial')),

  -- Estado
  is_active boolean not null,
  is_sandbox boolean not null,

  -- Fechas clave
  purchase_date timestamptz not null,
  expires_date timestamptz not null,
  grace_period_expires_date timestamptz,

  -- Info económica (opcional pero útil)
  price_amount numeric,
  price_currency text,

  -- Auditoría
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  -- 1 fila por usuario + producto
  unique (rc_app_user_id, rc_product_id)
);

ALTER TABLE subscription ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Read own subscription" ON subscription FOR SELECT TO authenticated USING (auth.uid() = user_id);
CREATE POLICY "Admins can read all subscriptions" ON subscription FOR SELECT TO authenticated USING (is_admin());
CREATE POLICY "Admins can update all subscriptions" ON subscription FOR UPDATE TO authenticated USING (is_admin());




CREATE TABLE preacher_role (
    id BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL
);



CREATE TABLE preacher (
    id BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    preacher_role_id BIGINT NULL,
    image_id TEXT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT fk_preacher_role FOREIGN KEY (preacher_role_id) REFERENCES preacher_role(id) ON DELETE SET NULL
);

CREATE TABLE collection_type (
    id BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL
);


----- is_public: true = acceso para todos los usuarios, false = acceso solo para usuarios específicos
CREATE TABLE collection (
    id BIGSERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT NULL,
    image_id TEXT NULL,
    collection_type_id BIGINT NULL,
    is_public BOOLEAN DEFAULT true,
    is_home_screen BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    ended_at DATE NULL,
    CONSTRAINT fk_collection_type FOREIGN KEY (collection_type_id) REFERENCES collection_type(id) ON DELETE SET NULL
);

CREATE TABLE preach (
    id BIGSERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT,
    date TIMESTAMPTZ NOT NULL,
    video_id TEXT NOT NULL,
    image_id TEXT NULL,
    preacher_id BIGINT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT fk_preacher FOREIGN KEY (preacher_id) REFERENCES preacher(id) ON DELETE SET NULL
);

-- INSERT INTO preach (title, description, date, video_url, preacher_id) VALUES ('Conociendo la visión', 'Primera lección de discipulado 2', '2025-01-01', 'url', 1);
-- INSERT INTO preach (title, description, date, video_url, preacher_id) VALUES ('Un corazón puro para ministrar', 'Segunda lección de discipulado 2', '2025-01-01', 'url', 1);
-- INSERT INTO preach (title, description, date, video_url, preacher_id) VALUES ('Líderes facilitadores', 'Cuarta lección de discipulado 2', '2025-01-01', 'url', 1);
-- INSERT INTO preach (title, description, date, video_url, preacher_id) VALUES ('Líderes que practican transparencia', 'Quinta lección de discipulado 2', '2025-01-01', 'url', 1);

-- INSERT INTO preach_collection_membership (preach_id, collection_id) VALUES (1, 5);
-- INSERT INTO preach_collection_membership (preach_id, collection_id) VALUES (2, 5);
-- INSERT INTO preach_collection_membership (preach_id, collection_id) VALUES (3, 5);
-- INSERT INTO preach_collection_membership (preach_id, collection_id) VALUES (4, 5);

-- Permite que un preach pertenezca a múltiples colecciones a la vez
-- Por ejemplo: un preach puede estar en una colección de tipo "Serie" y otra de tipo "Congreso", o estar en una colección privada y en una pública
CREATE TABLE collection_item (
    id BIGSERIAL PRIMARY KEY,
    preach_id BIGINT NOT NULL REFERENCES preach(id) ON DELETE CASCADE,
    collection_id BIGINT NOT NULL REFERENCES collection(id) ON DELETE CASCADE,
    position INTEGER NULL, -- Posición del preach dentro de la colección (para ordenar)
    added_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT unique_collection_item UNIQUE(preach_id, collection_id)
);

-- Solo se usa para colecciones con is_public = false
-- Relación muchos-a-muchos entre usuarios de Supabase auth.users y colecciones privadas
CREATE TABLE user_collection_access (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    collection_id BIGINT NOT NULL REFERENCES collection(id) ON DELETE CASCADE,
    granted_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    granted_at TIMESTAMPTZ DEFAULT NOW(),
    revoked_at TIMESTAMPTZ NULL,
    is_active BOOLEAN DEFAULT true,
    notes TEXT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT unique_user_collection UNIQUE(user_id, collection_id)
);

CREATE TABLE external_links (
    id BIGSERIAL PRIMARY KEY,
    key_link TEXT UNIQUE,
    link TEXT,
    is_enabled BOOLEAN DEFAULT TRUE
);

-- CREATE TABLE music_video (
--     id BIGSERIAL PRIMARY KEY,
--     song_name TEXT NOT NULL,
--     video_url TEXT NOT NULL,
--     image_id TEXT NULL
--     created_at TIMESTAMPTZ DEFAULT NOW(),
-- );

-- INSERT INTO music_video (song_name, video_url, thumb_id) VALUES ('Mi gozo', 'https://youtu.be/5ZmqvPkwqZM?si=nBDAq8X87gJrzwUr');
-- INSERT INTO music_video (song_name, video_url, thumb_id) VALUES ('Mi Dios es grande', 'https://youtu.be/V1Y3ebAPi1M?si=4V2rp2CxvsWp4Aav');
-- INSERT INTO music_video (song_name, video_url, thumb_id) VALUES ('La bondad de Dios', 'https://youtu.be/2y3P4VbIEi8?si=jgG5yb-Yed95x0Wn');
-- INSERT INTO music_video (song_name, video_url, thumb_id) VALUES ('Grande eres tú', 'https://youtu.be/2y3P4VbIEi8?si=_SV6ywyH5zMzsR8s');
-- INSERT INTO music_video (song_name, video_url, thumb_id) VALUES ('Planes de bien', 'Planes de bien');
-- INSERT INTO music_video (song_name, video_url, thumb_id) VALUES ('Identidad y propósito', 'https://youtu.be/VxhnE-Ls5IQ');



CREATE INDEX idx_preach_preacher ON preach(preacher_id);
CREATE INDEX idx_preach_fecha ON preach(date DESC);


CREATE INDEX idx_preach_collection_membership_preach ON collection_item(preach_id);
CREATE INDEX idx_preach_collection_membership_collection ON collection_item(collection_id);
CREATE INDEX idx_preach_collection_membership_position ON collection_item(collection_id, position);

CREATE INDEX idx_preach_collection_is_public ON collection(is_public);

CREATE INDEX idx_user_collection_access_user ON user_collection_access(user_id);
CREATE INDEX idx_user_collection_access_collection ON user_collection_access(collection_id);
CREATE INDEX idx_user_collection_access_active ON user_collection_access(user_id, is_active) WHERE is_active = true;


CREATE OR REPLACE FUNCTION user_has_collection_access(p_user_id UUID, p_collection_id BIGINT)
RETURNS BOOLEAN AS $$
DECLARE
    v_is_public BOOLEAN;
BEGIN
    -- Primero verificar si la colección es pública
    SELECT is_public INTO v_is_public
    FROM collection
    WHERE id = p_collection_id;
    
    -- Si es pública, todos los usuarios autenticados tienen acceso
    IF v_is_public = true THEN
        RETURN true;
    END IF;
    
    -- Si es privada, verificar si el usuario tiene acceso específico
    RETURN EXISTS (
        SELECT 1
        FROM user_collection_access
        WHERE user_id = p_user_id
        AND collection_id = p_collection_id
        AND is_active = true
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;



CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';


-- Función para actualizar collection cada vez que se le añade una predica
CREATE OR REPLACE FUNCTION update_collection_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE collection
  SET updated_at = NOW()
  WHERE id = NEW.collection_id;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para INSERT
CREATE TRIGGER trigger_update_collection_on_collection_item
AFTER INSERT ON collection_item
FOR EACH ROW
EXECUTE FUNCTION update_collection_timestamp();

CREATE OR REPLACE FUNCTION update_collection_timestamp_delete()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE collection
  SET updated_at = NOW()
  WHERE id = OLD.collection_id;
  
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trigger_update_collection_on_preach_delete
AFTER DELETE ON collection_item
FOR EACH ROW
EXECUTE FUNCTION update_collection_timestamp_delete();


CREATE TRIGGER update_preacher_updated_at BEFORE UPDATE ON preacher
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_preach_collection_updated_at BEFORE UPDATE ON collection
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_preach_updated_at BEFORE UPDATE ON preach
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_preach_collection_membership_updated_at BEFORE UPDATE ON collection_item
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_collection_access_updated_at BEFORE UPDATE ON user_collection_access
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_profile_update_at BEFORE UPDATE ON profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_profile_update_at BEFORE UPDATE ON subscription
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Políticas básicas de lectura pública (ajusta según tus necesidades)
-- preacher_role
ALTER TABLE preacher_role ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Enable read access for all users" ON preacher_role FOR SELECT TO authenticated USING (true);
CREATE POLICY "Admins can manage preacher roles" ON preacher_role
    FOR ALL TO authenticated USING (is_admin())
    WITH CHECK (is_admin());

-- collection_type
ALTER TABLE collection_type ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Enable read access for all users" ON collection_type FOR SELECT TO authenticated USING (true);
CREATE POLICY "Admins can manage collection types" ON collection_type
    FOR ALL TO authenticated USING (is_admin())
    WITH CHECK (is_admin());


ALTER TABLE preach ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Enable read access for all users" ON preach FOR SELECT TO authenticated USING (true);
CREATE POLICY "Admins can manage preach" ON preach FOR ALL TO authenticated
    USING (is_admin())
    WITH CHECK (is_admin());


ALTER TABLE collection_item ENABLE ROW LEVEL SECURITY;
-- Solo administradores pueden crear, actualizar o eliminar membresías
CREATE POLICY "Admins can manage collection memberships" ON collection_item
    FOR ALL TO authenticated USING (is_admin())
    WITH CHECK (is_admin());
CREATE POLICY "Users can view collection memberships for accessible collections" ON collection_item
FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM collection pc
        WHERE pc.id = collection_item.collection_id
        AND (
            pc.is_public = true
            OR EXISTS (
                SELECT 1 FROM user_collection_access uca
                WHERE uca.collection_id = pc.id
                AND uca.user_id = auth.uid()
                AND uca.is_active = true
            )
        )
    )
);



ALTER TABLE user_collection_access ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view their own collection access" ON user_collection_access
    FOR SELECT TO authenticated USING (auth.uid() = user_id AND is_active = true);
CREATE POLICY "Admins can manage collection access" ON user_collection_access
    FOR ALL TO authenticated USING (is_admin())
    WITH CHECK (is_admin());


ALTER TABLE collection ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view public collections" ON collection 
    FOR SELECT TO authenticated USING (is_public = true);
CREATE POLICY "Users can view private collections they have access to" ON collection
    FOR SELECT TO authenticated USING (
        is_public = false 
        AND EXISTS (
            SELECT 1 FROM user_collection_access uca
            WHERE uca.collection_id = collection.id
            AND uca.user_id = auth.uid()
            AND uca.is_active = true
        )
    );
CREATE POLICY "Admins can manage collections" ON collection
FOR ALL TO authenticated USING (is_admin())
WITH CHECK (is_admin());

ALTER TABLE preacher ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Enable read access for all users" ON preacher FOR SELECT TO authenticated USING (true);
CREATE POLICY "Admins can manage preachers" ON preacher FOR ALL TO authenticated USING (is_admin())
    WITH CHECK (is_admin());



-- Solo administradores (profile_role = 'admin') pueden crear, actualizar o eliminar predicaciones

-- ALTER TABLE music_video ENABLE ROW LEVEL SECURITY;
-- CREATE POLICY "Enable read access for all users" ON music_video FOR SELECT TO authenticated USING (true);
-- CREATE POLICY "Admins can manage music videos" ON music_video FOR ALL  TO authenticated USING (is_admin())
--     WITH CHECK (is_admin());
-- Política para preach_collection_membership
-- Los usuarios solo pueden ver membresías de colecciones a las que tienen acceso



-- Políticas para preach_collection
-- Los usuarios autenticados pueden ver colecciones públicas
-- Las colecciones privadas solo son visibles para usuarios con acceso específico

-- Los usuarios pueden ver colecciones privadas si tienen acceso activo en user_collection_access


-- Solo administradores pueden crear, actualizar o eliminar colecciones


-- Políticas para user_collection_access
-- Los usuarios solo pueden ver sus propios accesos activos


-- Solo administradores pueden insertar, actualizar o eliminar accesos a colecciones

