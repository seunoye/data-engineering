# Encrypted Google Service Account Setup for Kestra

## Setup Instructions

### 1. Generate Encryption Key

Generate a secure random encryption key (minimum 32 characters):

```bash
openssl rand -base64 32
```

### 2. Create .env file

Copy `.env.example` to `.env` and add your encryption key:

```bash
cp .env.example .env
```

Edit `.env` and replace with your generated key:

```
KESTRA_ENCRYPTION_KEY=<your-generated-key-here>
```

### 3. Start Kestra

```bash
docker compose up -d
```

### 4. Add Google Credentials and Configuration

**Best Practice:** Store sensitive credentials in **Secrets** (global) and configuration values in **KV Store** (namespace-specific).

#### A. Add Service Account to Secrets (Global)

1. Open http://localhost:8080
2. Login with: admin@kestra.io / Admin1234
3. Go to **Settings** → **Secrets**
4. Click **+ Add** button
5. Add your service account:
   - **Key**: `GCP_CREDS`
   - **Value**: Paste your **entire service account JSON** file content
     ```json
     {
       "type": "service_account",
       "project_id": "my-project",
       "private_key_id": "...",
       "private_key": "-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n",
       "client_email": "...",
       "client_id": "...",
       "auth_uri": "https://accounts.google.com/o/oauth2/auth",
       "token_uri": "https://oauth2.googleapis.com/token",
       "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
       "client_x509_cert_url": "..."
     }
     ```

6. Click **Save**

#### B. Add Configuration to KV Store (Per Namespace)

1. Navigate to your namespace (e.g., **zoomcamp** or **data_engineering**)
2. Go to **KV Store** tab
3. Click **+ Add** and create these entries:
   - **Key**: `GCP_PROJECT_ID` → **Value**: `your-project-123`
   - **Key**: `GCP_LOCATION` → **Value**: `us-central1` (or your preferred region)
   - **Key**: `GCP_BUCKET_NAME` → **Value**: `your-unique-bucket-name`
   - **Key**: `GCP_DATASET` → **Value**: `ny_taxi` (or your dataset name)

4. Click **Save** for each entry

### 5. How Encryption Works

- **KV Store** values are encrypted at rest using AES-256-GCM encryption
- The `KESTRA_ENCRYPTION_KEY` is used to encrypt/decrypt all values
- KV Store is namespace-specific - each namespace has isolated storage
- Values are only decrypted in memory when flows execute
- **NEVER commit your `.env` file or encryption key to git**

### 6. Use in Flows

Reference all KV Store values using the `kv()` function:

````yaml
pluginDefaults:
  - type: io.kestra.plugin.gcp
    values:
      serviceAccount: "{{ kv('GCP_CREDS') }}"
      projectId: "{{ kv('GCP_PROJECT_ID') }}"
      location: "{{ kv('GCP_LOCATION') }}"
      bucket: "{{ kv('GCP_BUCKET_NAME') }}"

```yaml
serviceAccount: "{{ kv('GCP_CREDS') }}"
projectId: "{{ kv('GCP_PROJECT_ID') }}"
````

### Alternative: Use Google Secret Manager

For production, consider using Google Secret Manager:

```yaml
tasks:
  - id: get_secret
    type: io.kestra.plugin.gcp.secretmanager.Get
    projectId: "{{ secret('GCP_PROJECT_ID') }}"
    serviceAccount: "{{ secret('GCP_SERVICE_ACCOUNT') }}"
    secret: my-secret-name
    version: latest
```

## Security Best Practices

1. ✅ Use strong encryption keys (32+ characters)
2. ✅ Store encryption key in environment variables
3. ✅ Never commit `.env` file or credentials to git
4. ✅ Rotate encryption keys periodically
5. ✅ Use Google Secret Manager for production
6. ✅ Limit service account permissions (principle of least privilege)
7. ✅ Enable audit logging on GCP

## Rotating Encryption Key

If you need to change the encryption key:

1. Export all secrets from Kestra UI
2. Stop Kestra
3. Update `KESTRA_ENCRYPTION_KEY` in `.env`
4. Start Kestra
5. Re-add all secrets via UI (they'll be encrypted with new key)
