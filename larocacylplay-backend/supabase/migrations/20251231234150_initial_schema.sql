-- ✅ Profiles roles --
CREATE TYPE profile_role AS ENUM ('admin', 'suscriber', 'member');
-- ✅ Tabla de perfiles, asociada a los usuarios
CREATE TABLE profile (
    user_id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    display_name TEXT,
    email TEXT,
    avatar_url TEXT,
    avatar_id TEXT,
    locale TEXT DEFAULT 'es',
    profile_role profile_role default 'member',
    created_at timestamptz default now(),
    updated_at timestamptz default now()
);
-- ✅ Función para verificar si el usuario actual es administrador. Helper para RLS
CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM profile p
        WHERE p.user_id = auth.uid()
        AND p.profile_role = 'admin'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
-- ✅ RLS para profiles
ALTER TABLE profile ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Read own profile" ON profile FOR SELECT TO authenticated USING (auth.uid() = user_id);
CREATE POLICY "Update own profile" ON profile FOR UPDATE TO authenticated USING (auth.uid() = user_id);
CREATE POLICY "Admins can read all profiles" ON profile FOR SELECT TO authenticated USING (is_admin());
CREATE POLICY "Admins can update all profiles" ON profile FOR UPDATE TO authenticated USING (is_admin());

-- ✅ Tabla para user_notification_settings
CREATE TABLE user_notification_settings (
    user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    notify_main_collection BOOLEAN DEFAULT true,        -- Colección ID 1
    notify_new_public_collections BOOLEAN DEFAULT true, -- Nuevas col. públicas
    notify_private_access BOOLEAN DEFAULT true,         -- Cuando le dan acceso a una privada
    notify_public_content BOOLEAN DEFAULT true,         -- Contenido en col. públicas
    notify_private_content BOOLEAN DEFAULT true,        -- Contenido en sus col. privadas
    notify_youtube_live BOOLEAN DEFAULT true            -- YouTube Live
);
ALTER TABLE user_notification_settings ENABLE ROW LEVEL SECURITY;
-- Ver mis propios ajustes
CREATE POLICY "Users can view their own settings" ON user_notification_settings FOR SELECT TO authenticated USING (auth.uid() = user_id);
-- Actualizar mis propios ajustes
CREATE POLICY "Users can update their own settings" ON user_notification_settings FOR UPDATE TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- ✅ Tabla para user_devices
CREATE TABLE public.user_devices (
    device_id TEXT PRIMARY KEY, -- ID único del hardware (VendorID en iOS / AndroidID)
    user_id UUID NOT NULL REFERENCES public.user_notification_settings(user_id) ON DELETE CASCADE,
    fcm_token TEXT NOT NULL,
    device_name TEXT,
    device_type TEXT CHECK (device_type IN ('ios', 'android')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    last_seen TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_user_devices_user_id ON public.user_devices(user_id);
ALTER TABLE user_devices ENABLE ROW LEVEL SECURITY;
-- Ver mis dispositivos
CREATE POLICY "Users can view their own devices" ON user_devices FOR SELECT TO authenticated USING (auth.uid() = user_id);
-- Registrar un nuevo dispositivo (FCM Token)
CREATE POLICY "Users can insert their own devices" ON user_devices FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
-- Actualizar un token existente
CREATE POLICY "Users can update their own devices" ON user_devices FOR UPDATE TO authenticated USING (auth.uid() = user_id);
-- Borrar dispositivo (al hacer Logout)
CREATE POLICY "Users can delete their own devices" ON user_devices FOR DELETE TO authenticated USING (auth.uid() = user_id);



-- ✅ Tabla para notifications
CREATE TABLE notification (
    id BIGSERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    payload JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE notification ENABLE ROW LEVEL SECURITY;
CREATE POLICY "All users can read notifications" ON notification FOR SELECT TO AUTHENTICATED USING (true);

CREATE TABLE user_notification (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    notification_id BIGINT REFERENCES public.notification(id) ON DELETE CASCADE,
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE user_notification ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view their own notifications" ON user_notification FOR SELECT TO authenticated USING (auth.uid() = user_id);
CREATE POLICY "Users can update their own notifications" ON user_notification FOR UPDATE TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete their own notifications" ON user_notification FOR DELETE TO authenticated USING (auth.uid() = user_id);



-- ✅ Función que crea un nuevo perfil cuando hay un nuevo usuario --
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
as $$
BEGIN
-- Verificamos que tenga email y que NO sea anónimo
  IF NEW.email IS NOT NULL AND (NEW.raw_app_meta_data->>'is_anonymous')::boolean IS DISTINCT FROM true THEN
    INSERT INTO public.profile (user_id, email, display_name)
    VALUES (
      NEW.id,
      NEW.email,
      split_part(NEW.email, '@', 1)
      )
    ON CONFLICT (user_id) DO UPDATE
    SET
      email = EXCLUDED.email;
    INSERT INTO public.user_notification_settings (user_id)
    VALUES (NEW.id)
    ON CONFLICT (user_id) DO NOTHING;
  END IF;
  RETURN NEW;
END;
$$;
-- ✅ Trigger on auth user created or updated
CREATE TRIGGER on_auth_user_created_or_updated
AFTER INSERT OR UPDATE OF email, raw_app_meta_data ON auth.users
FOR EACH ROW
EXECUTE FUNCTION public.handle_new_user();

CREATE OR REPLACE FUNCTION logout_all_devices(target_user_id UUID)
RETURNS VOID AS $$
BEGIN
  -- 1. Invalida todas las sesiones de Auth para este usuario
  DELETE FROM auth.sessions WHERE user_id = target_user_id;
  
  -- 2. Borra todos sus dispositivos de notificaciones para evitar "zombies"
  DELETE FROM public.user_devices WHERE user_id = target_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
CREATE OR REPLACE FUNCTION delete_user_account()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  DELETE FROM auth.users WHERE id = auth.uid();
END;
$$;



-- ✅ Tabla para revenuecat events --
CREATE TABLE IF NOT EXISTS revenuecat_event (
  id BIGSERIAL PRIMARY KEY,
  event_id TEXT NOT NULL UNIQUE, -- ID único del evento de RevenueCat
  event_type TEXT NOT NULL, -- Tipo de evento: INITIAL_PURCHASE, RENEWAL, CANCELLATION, etc.
  app_user_id UUID NOT NULL, -- RevenueCat app_user_id (UUID del usuario)
  payload JSONB NOT NULL, -- Payload completo del evento para referencia
  created_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT fk_user_id FOREIGN KEY (app_user_id) REFERENCES profile(user_id) ON DELETE NO ACTION
);

-- ✅ Tabla para subscription
CREATE TABLE public.subscription (
    -- 1. Identificadores y Relación
    id bigserial PRIMARY KEY,
    user_id uuid NOT NULL REFERENCES public.profile(user_id) ON DELETE CASCADE,
    is_sandbox boolean not null,

    -- 2. Estado de Acceso (Tu lógica de separación)
    is_active boolean DEFAULT false, -- Uso en App: ¿Tiene permiso?
    status_type text NOT NULL,       -- Uso Marketing: trialing, active, expired, grace_period, refunded

    -- 3. Control de Duplicados (Tu propuesta de UNIQUE)
    last_event_id text UNIQUE,       -- Evita procesar el mismo webhook dos veces

    -- 4. Detalles del Producto
    product_id text NOT NULL,        -- ID del plan (ej: mensual_premium)
    store text,                      -- app_store, play_store, stripe
    period_type text,                -- NORMAL, TRIAL, INTRO

    -- 5. Fechas para Marketing y Segmentación
    expires_at timestamptz,          -- Cuándo caduca
    will_renew boolean DEFAULT true, -- Si tiene la renovación activa
    unsubscribed_at timestamptz,     -- Cuándo canceló (para recuperación de bajas)

    -- 6. Auditoría
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);
-- Índices para que tus filtros de marketing sean instantáneos
CREATE INDEX idx_sub_segmentacion ON public.subscription(is_active, status_type);
CREATE INDEX idx_sub_vencimiento ON public.subscription(expires_at);
-- ✅ RLS para subscription
ALTER TABLE subscription ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Read own subscription" ON subscription FOR SELECT TO authenticated USING (auth.uid() = user_id);
CREATE POLICY "Admins can read all subscriptions" ON subscription FOR SELECT TO authenticated USING (is_admin());
CREATE POLICY "Admins can update all subscriptions" ON subscription FOR UPDATE TO authenticated USING (is_admin());



-- ✅ Tabla Preacher Role (Rol de Predicador)
CREATE TABLE preacher_role (
    id BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL
);
-- ✅ Habilitar Row Level Security (RLS) - Supabase best practice
ALTER TABLE preacher_role ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Enable read access for all users" ON preacher_role FOR SELECT TO authenticated USING (true);
CREATE POLICY "Admins can manage preacher roles" ON preacher_role
    FOR ALL TO authenticated USING (is_admin())
    WITH CHECK (is_admin());


-- ✅ Tabla Preacher (Predicador)
CREATE TABLE preacher (
    id BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    preacher_role_id BIGINT NULL,
    image_id TEXT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT fk_preacher_role FOREIGN KEY (preacher_role_id) REFERENCES preacher_role(id) ON DELETE SET NULL
);
ALTER TABLE preacher ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Enable read access for all users" ON preacher FOR SELECT TO authenticated USING (true);
CREATE POLICY "Admins can manage preachers" ON preacher FOR ALL TO authenticated USING (is_admin())
    WITH CHECK (is_admin());

-- ✅ Tabla Preach (Predicación)
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

-- ✅ Índices para mejorar el rendimiento
CREATE INDEX idx_preach_preacher ON preach(preacher_id);
CREATE UNIQUE INDEX unique_image_id_on_preaches ON preach (image_id) WHERE image_id IS NOT NULL;
CREATE INDEX idx_preach_fecha ON preach(date DESC);
ALTER TABLE preach ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Enable read access for all users" ON preach FOR SELECT TO authenticated USING (true);
CREATE POLICY "Admins can manage preach" ON preach FOR ALL TO authenticated
    USING (is_admin())
    WITH CHECK (is_admin());


-- ✅ Tabla CollectionType (Tipo de Colección)
CREATE TABLE collection_type (
    id BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL
);

-- ✅ collection_type
ALTER TABLE collection_type ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Enable read access for all users" ON collection_type FOR SELECT TO authenticated USING (true);
CREATE POLICY "Admins can manage collection types" ON collection_type
    FOR ALL TO authenticated USING (is_admin())
    WITH CHECK (is_admin());



-- ✅ Tabla PreachCollection (Colección de Predicaciones)
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
CREATE INDEX idx_collection_is_public ON collection(is_public);
CREATE INDEX idx_collection_image_id ON collection(image_id) WHERE image_id IS NOT NULL;
-- ✅ Tabla Preach Collection Membership (Relación muchos-a-muchos entre Preach y PreachCollection)
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
CREATE INDEX idx_collection_item_preach ON collection_item(preach_id);
CREATE INDEX idx_collection_item_collection ON collection_item(collection_id);
CREATE INDEX idx_collection_item_position ON collection_item(collection_id, position);
-- ✅ Tabla User Collection Access (Acceso de Usuario a Colecciones Privadas)
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
CREATE INDEX idx_user_collection_access_user ON user_collection_access(user_id);
CREATE INDEX idx_user_collection_access_collection ON user_collection_access(collection_id);
CREATE INDEX idx_user_collection_access_active ON user_collection_access(user_id, is_active) WHERE is_active = true;
-- ✅ Función para verificar si un usuario tiene acceso a una colección
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

ALTER TABLE collection ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Admins can manage collections" ON collection FOR ALL TO authenticated USING (is_admin()) WITH CHECK (is_admin());
CREATE POLICY "Users can view accessible collections" ON collection
    FOR SELECT TO authenticated 
    USING (user_has_collection_access(auth.uid(), id));

ALTER TABLE collection_item ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view collection items for accessible collections" ON collection_item
    FOR SELECT TO authenticated 
    USING (user_has_collection_access(auth.uid(), collection_id));
CREATE POLICY "Admins can manage collection memberships" ON collection_item
    FOR ALL TO authenticated USING (is_admin())
    WITH CHECK (is_admin());

-- ✅ Índices para user_collection_access
ALTER TABLE user_collection_access ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Admins can manage collection access" ON user_collection_access
    FOR ALL TO authenticated USING (is_admin())
    WITH CHECK (is_admin());
CREATE POLICY "Users can view their own collection access" ON user_collection_access
    FOR SELECT TO authenticated USING (user_has_collection_access(auth.uid(), collection_id));
-- ✅ Función para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';
CREATE OR REPLACE FUNCTION update_collection_items_on_preach_change()
RETURNS TRIGGER AS $$
BEGIN
    -- Buscamos todas las relaciones en la tabla intermedia
    -- y forzamos un update para que salten los triggers hacia la colección
    UPDATE collection_item
    SET updated_at = NOW()
    WHERE preach_id = NEW.id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER tr_preach_updated
AFTER UPDATE ON preach
FOR EACH ROW
WHEN (OLD.* IS DISTINCT FROM NEW.*) -- Solo si hubo cambios reales
EXECUTE FUNCTION update_collection_items_on_preach_change();
-- ✅ Función para actualizar collection cada vez que en collection_item se elimina una predicación
CREATE OR REPLACE FUNCTION update_collection_on_collection_item_delete()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE collection
  SET updated_at = NOW()
  WHERE id = OLD.collection_id;

  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- ✅ Trigger para DELETE
CREATE TRIGGER tr_update_collection_on_collection_item_delete
AFTER DELETE ON collection_item
FOR EACH ROW
EXECUTE FUNCTION update_collection_on_collection_item_delete();
-- ✅ Función para actualizar collection cada vez que se añade o actualiza un collection_item
CREATE OR REPLACE FUNCTION update_collection_on_collection_item_change()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE collection
  SET updated_at = NOW()
  WHERE id = NEW.collection_id;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
-- ✅ Trigger para INSERT
CREATE TRIGGER tr_update_collection_on_collection_item_insert_or_update
AFTER INSERT OR UPDATE ON collection_item
FOR EACH ROW
EXECUTE FUNCTION update_collection_on_collection_item_change();





-- ✅ Tabla External Links
CREATE TABLE external_link (
    id BIGSERIAL PRIMARY KEY,
    key_link TEXT UNIQUE,
    link TEXT,
    is_enabled BOOLEAN DEFAULT TRUE
);
ALTER TABLE external_link ENABLE ROW LEVEL SECURITY;
CREATE POLICY "All users can read external links" ON external_link FOR SELECT TO AUTHENTICATED USING (true);
CREATE POLICY "Admins can manage external links" ON external_link FOR ALL TO AUTHENTICATED USING (is_admin());

-- ✅ Tabla song --
CREATE TABLE song (
  id BIGSERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  video_id TEXT NOT NULL UNIQUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE song ENABLE ROW LEVEL SECURITY;
CREATE POLICY "All users can read songs" ON song FOR SELECT TO AUTHENTICATED USING (true);
CREATE POLICY "Admins can add songs" ON song FOR INSERT TO AUTHENTICATED WITH CHECK (is_admin());




-- ALTER TABLE user_collection_access ENABLE ROW LEVEL SECURITY;
-- CREATE POLICY "Users can view their own collection access" ON user_collection_access
--     FOR SELECT TO authenticated USING (auth.uid() = user_id AND is_active = true);


-- ✅ Triggers para actualizar updated_at en cada tabla
CREATE TRIGGER tr_update_preacher_updated_at BEFORE UPDATE ON preacher
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER tr_update_collection_updated_at BEFORE UPDATE ON collection
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER tr_update_preach_updated_at BEFORE UPDATE ON preach
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER tr_update_collection_item_updated_at BEFORE UPDATE ON collection_item
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER tr_update_user_collection_access_updated_at BEFORE UPDATE ON user_collection_access
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER tr_update_profiles_updated_at BEFORE UPDATE ON profile
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER tr_update_subscription_updated_at BEFORE UPDATE ON subscription
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();



CREATE OR REPLACE VIEW v_target_tokens_by_collection AS
SELECT
    ud.fcm_token,
    ud.user_id,
    c.id AS collection_id,
    c.is_public,
    ud.device_type
FROM public.user_devices ud
JOIN public.user_notification_settings uns ON ud.user_id = uns.user_id
CROSS JOIN public.collection c
LEFT JOIN user_collection_access uca ON (c.id = uca.collection_id AND uca.user_id = ud.user_id AND uca.is_active = true)
WHERE
    -- 1. Si es la colección principal (ID 1), verificar ajuste específico
    (c.id = 1 AND uns.notify_main_collection = true)
    OR
    -- 2. Si es una colección pública (no la 1), verificar ajuste de contenido público
    (c.id != 1 AND c.is_public = true AND uns.notify_public_content = true)
    OR
    -- 3. Si es una colección privada, el usuario DEBE tener acceso y el ajuste activo
    (c.is_public = false AND uca.id IS NOT NULL AND uns.notify_private_content = true);


CREATE OR REPLACE FUNCTION get_tokens_for_collection_item(p_collection_id BIGINT)
RETURNS TABLE(fcm_token TEXT) AS $$
BEGIN
    RETURN QUERY
    SELECT v.fcm_token
    FROM v_target_tokens_by_collection v
    WHERE v.collection_id = p_collection_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;







-- STORAGE
INSERT INTO storage.buckets (id, name, public)
VALUES ('app', 'app', true)
ON CONFLICT (id) DO NOTHING;

CREATE POLICY "Lectura para autenticados"
ON storage.objects FOR SELECT
TO authenticated
USING (bucket_id = 'app');

CREATE POLICY "Inserción para admins"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'app' AND
  (public.is_admin())
);
CREATE POLICY "Borrado para admins"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'app' AND
  (public.is_admin())
);
CREATE POLICY "Actualización para admins"
ON storage.objects FOR UPDATE
TO authenticated
WITH CHECK (
  bucket_id = 'app' AND
  (public.is_admin())
);


CREATE OR REPLACE FUNCTION public.handle_storage_metadata_updates()
RETURNS TRIGGER AS $$
DECLARE
  _target_id bigint;
  _target_table text;
  _just_filename text;
BEGIN
  -- Extraemos los metadatos que envías desde la App/Backend
  _target_id := (NEW.user_metadata ->> 'target_id')::bigint;
  _target_table := (NEW.user_metadata ->> 'table_target');

  IF _target_id IS NULL OR _target_table IS NULL THEN
    _target_id := (NEW.metadata ->> 'target_id')::bigint;
    _target_table := (NEW.metadata ->> 'table_target');
  END IF;

  IF _target_id IS NULL OR _target_table IS NULL THEN RETURN NEW;
  END IF;

  -- Obtenemos solo el nombre (ej: "foto.jpg") sin el prefijo de la carpeta
  _just_filename := reverse(split_part(reverse(NEW.name), '/', 1));

  -- Actualizamos la tabla. Tu trigger de updated_at hará el resto.
  IF _target_table = 'preach' THEN
    UPDATE public.preach SET image_id = _just_filename WHERE id = _target_id;
  ELSIF _target_table = 'collection' THEN
    UPDATE public.collection SET image_id = _just_filename WHERE id = _target_id;
  ELSIF _target_table = 'preacher' THEN
    UPDATE public.preacher SET image_id = _just_filename WHERE id = _target_id;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, storage;

-- Trigger para cuando subes o cambias una imagen
CREATE TRIGGER on_image_uploaded_or_updated
  AFTER INSERT OR UPDATE ON storage.objects
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_storage_metadata_updates();

CREATE OR REPLACE FUNCTION public.handle_storage_delete_reference()
RETURNS TRIGGER AS $$
DECLARE
  _folder_name text;
  _just_filename text;
BEGIN
  -- 1. Extraemos la carpeta (ej: 'bannerPreaches')
  _folder_name := split_part(OLD.name, '/', 1);

  -- 2. Extraemos solo el nombre del archivo (ej: 'foto123.jpg')
  _just_filename := reverse(split_part(reverse(OLD.name), '/', 1));

  -- 3. Limpiamos SOLO la tabla que corresponde a esa carpeta
  CASE _folder_name
    WHEN 'preach' THEN
      UPDATE public.preach SET image_id = NULL WHERE image_id = _just_filename;

    WHEN 'collection' THEN -- Ajusta al nombre real de tu carpeta
      UPDATE public.collection SET image_id = NULL WHERE image_id = _just_filename;

    WHEN 'preacher' THEN -- Ajusta al nombre real de tu carpeta
      UPDATE public.preacher SET image_id = NULL WHERE image_id = _just_filename;
  END CASE;

  RETURN OLD;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, storage;

CREATE TRIGGER on_image_deleted
  AFTER DELETE ON storage.objects
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_storage_delete_reference();