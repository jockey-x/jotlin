<div align="center">
  <img src="public/logo.svg" alt="Jotlin" width="120" height="120" />
  <h1>Jotlin</h1>
  <p><strong>The missing layer between idea and code</strong></p>

  <p>
    <a href="#features">Features</a> •
    <a href="#quick-start">Quick Start</a> •
    <a href="#documentation">Documentation</a> •
    <a href="#contributing">Contributing</a>
  </p>

  <!-- Add badges here when ready -->
  <!-- ![License](https://img.shields.io/badge/license-MIT-blue.svg) -->
  <!-- ![TypeScript](https://img.shields.io/badge/TypeScript-5.0-blue) -->
</div>

---

## What is Jotlin?

Jotlin is an AI-powered specification assistant that transforms rough ideas into production-ready documentation through intelligent conversation. Instead of staring at a blank document, you simply describe your project idea, and Jotlin guides you through a structured interview to generate comprehensive PRDs, user stories, and technical specifications.

**Stop writing specs from scratch. Start having conversations that generate them.**

### Why Jotlin?

- **Natural Interaction**: Chat naturally about your ideas instead of filling out templates
- **Intelligent Guidance**: AI asks the right questions to uncover requirements you might miss
- **Structured Output**: Generate professional documentation that your team can use immediately
- **Iterative Refinement**: Continuously improve specs through ongoing conversations
- **Context Preservation**: All conversations and artifacts are preserved for future reference

## Features

### Core Capabilities

- **🎯 AI-Powered Interviews** - Intelligent questioning system that guides you from vague ideas to concrete specifications
- **📝 Multi-Format Artifacts** - Generate PRDs, user stories, flow diagrams, risk assessments, and technical docs
- **💬 Conversational UI** - Modern chat interface with real-time streaming responses
- **📊 Artifact Management** - View, edit, and iterate on generated specifications
- **🔍 Context-Aware** - Maintains conversation context across sessions

### Technical Highlights

- **⚡ Real-time Streaming** - Powered by Vercel AI SDK for instant feedback
- **🎨 Modern UI** - Built with Next.js 15, React 19, and shadcn/ui components
- **🔐 Secure Authentication** - GitHub OAuth with Better Auth
- **💾 Persistent Storage** - PostgreSQL with Prisma ORM
- **📱 Responsive Design** - Works seamlessly across desktop and mobile
- **🌐 Internationalization Ready** - Built-in i18n support

## Quick Start

### Prerequisites

Ensure you have the following installed:

- **Node.js** 18.x or higher
- **PostgreSQL** 14.x or higher
- **npm** or **pnpm**

### Installation

1. **Clone the repository**

```bash
git clone https://github.com/yourusername/jotlin.git
cd jotlin
```

2. **Install dependencies**

```bash
npm install
```

3. **Set up environment variables**

Create a `.env` file in the root directory:

```bash
# Database
DATABASE_URL="postgresql://username:password@localhost:5432/jotlin"

# Base URL
NEXT_PUBLIC_BASE_URL="http://localhost:3000"

# OpenAI
OPENAI_API_KEY="your-openai-api-key"
OPENAI_API_BASE_URL="https://api.openai.com/v1"

# GitHub OAuth (see setup guide below)
GITHUB_CLIENT_ID="your-github-client-id"
GITHUB_CLIENT_SECRET="your-github-client-secret"

# JWT Secrets
SEALOS_JWT_SECRET="your-sealos-jwt-secret"  # Optional: for Sealos integration
JWT_SECRET="your-jwt-secret"

# Claude Agent SDK (for AI code generation features)
ANTHROPIC_BASE_URL="https://api.anthropic.com"
ANTHROPIC_AUTH_TOKEN="your-anthropic-api-key"
ANTHROPIC_MODEL="claude-sonnet-4-5-20250929"  # Optional: defaults to this model
```

4. **Initialize the database**

```bash
npx prisma migrate dev
npx prisma generate
```

5. **Start the development server**

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) in your browser.

### GitHub OAuth Setup

1. Navigate to [GitHub Developer Settings](https://github.com/settings/developers)
2. Create a new OAuth App with:
   - **Application name**: `Jotlin`
   - **Homepage URL**: `http://localhost:3000`
   - **Authorization callback URL**: `http://localhost:3000/api/auth/callback/github`
3. Copy the Client ID and Client Secret to your `.env` file

## Documentation

### Project Structure

```
jotlin/
├── app/                    # Next.js App Router
│   ├── (app)/             # Authenticated routes
│   ├── api/               # API endpoints
│   └── preview/           # Public preview pages
├── components/            # React components
│   ├── ui/               # Base UI components (shadcn/ui)
│   ├── chat/             # Chat-specific components
│   └── auth/             # Authentication components
├── hooks/                 # Custom React hooks
├── libs/                  # Utility libraries
├── prisma/               # Database schema & migrations
├── public/               # Static assets
└── store/                # State management (Zustand)
```

### Architecture

Jotlin follows a modern full-stack architecture:

- **Frontend**: Next.js 15 with React Server Components
- **Backend**: Next.js API Routes with type-safe endpoints
- **Database**: PostgreSQL with Prisma ORM
- **Authentication**: Better Auth with GitHub OAuth
- **AI Integration**: Vercel AI SDK with streaming support
- **State Management**: Zustand for client-side state

For detailed architecture documentation, see [CLAUDE.md](./CLAUDE.md).

## Tech Stack

<table>
  <tr>
    <td><strong>Framework</strong></td>
    <td>Next.js 15.5, React 19</td>
  </tr>
  <tr>
    <td><strong>Language</strong></td>
    <td>TypeScript 5</td>
  </tr>
  <tr>
    <td><strong>Styling</strong></td>
    <td>Tailwind CSS 4, shadcn/ui</td>
  </tr>
  <tr>
    <td><strong>Database</strong></td>
    <td>PostgreSQL, Prisma</td>
  </tr>
  <tr>
    <td><strong>Authentication</strong></td>
    <td>Better Auth</td>
  </tr>
  <tr>
    <td><strong>AI SDK</strong></td>
    <td>Vercel AI SDK, Anthropic Claude</td>
  </tr>
  <tr>
    <td><strong>State Management</strong></td>
    <td>Zustand, React Query</td>
  </tr>
</table>

## Deployment

### Docker

Build the Docker image:

```bash
docker build -t jotlin:latest . --platform=linux/amd64
```

Run the container:

```bash
docker run -p 3000:3000 --env-file .env jotlin:latest
```

### CI/CD Image Build

The repository includes a GitHub Actions workflow for building and publishing Docker images to GitHub Container Registry:

- Workflow file: [`.github/workflows/docker-image.yml`](./.github/workflows/docker-image.yml)
- Default application image: `ghcr.io/jockey-x/jotlin`
- Default migration image: `ghcr.io/jockey-x/jotlin-migrate`

Trigger behavior:

- Pull requests targeting `main` build the image only and do not push
- Pushes to `main` build and push an image
- Tags matching `v*` build and push versioned images
- Manual runs from GitHub Actions support optional image push via `push_image=true`

Generated image tags include:

- Branch name tags for branch builds
- PR tags for pull request builds
- `sha-<commit>` tags
- Semantic version tags when pushing tags like `v1.2.3`
- `latest` for the default branch

Both images are built by the same workflow:

- [`Dockerfile`](/Users/shoufengxia/Desktop/Code/jotlin/Dockerfile) builds the runtime application image
- [`Dockerfile.migrate`](/Users/shoufengxia/Desktop/Code/jotlin/Dockerfile.migrate) builds the Prisma migration image

Before using the workflow, make sure:

1. GitHub Actions has `Read and write permissions` enabled for the repository
2. GitHub Container Registry packages are allowed for this repository

After that, pushing to `main` will publish a new image automatically:

```bash
git push origin main
```

To publish a release image manually with semantic version tags:

```bash
git tag v0.1.0
git push origin v0.1.0
```

### Helm

The repository includes a Helm chart for deploying Jotlin to Kubernetes:

- Chart path: [`helm/jotlin`](./helm/jotlin)
- Default image repository: `ghcr.io/jockey-x/jotlin`

Render the chart locally:

```bash
helm template jotlin ./helm/jotlin
```

An example production override file is included at [`helm/jotlin/values.prod.yaml`](./helm/jotlin/values.prod.yaml):

Copy it and replace the placeholder values before deployment.

Install or upgrade the release:

```bash
helm upgrade --install jotlin ./helm/jotlin \
  --namespace jotlin \
  --create-namespace \
  -f ./helm/jotlin/values.prod.yaml
```

Important notes:

- The current chart injects application secrets from a Kubernetes `Secret` generated by Helm values
- The chart includes an optional migration `Job`
- When enabled, the migration job runs automatically before every `helm install` and `helm upgrade` via Helm hooks
- Do not point the migration job at the current runtime image unless that image includes `prisma` CLI and the `prisma/` schema files
- For production, use a dedicated migration image and enable the job with values like `migrationJob.enabled=true`
- If you do not use Sealos login or S3-backed avatars, you can leave those related values empty
- OAuth callback URLs must match `NEXT_PUBLIC_BASE_URL`

Example migration job values:

```yaml
migrationJob:
  enabled: true
  image:
    repository: ghcr.io/jockey-x/jotlin-migrate
    tag: "0.1.0"
  command:
    - sh
    - -c
    - npx prisma migrate deploy
```

### Sealos

The repository also includes a Sealos-oriented packaging layout for building a cluster image from the Helm chart:

- Sealos directory: [`deploy/sealos`](./deploy/sealos)
- Kubefile: [`deploy/sealos/Kubefile`](./deploy/sealos/Kubefile)
- Chart directory: [`deploy/sealos/charts/jotlin`](./deploy/sealos/charts/jotlin)
- Sealos values file: [`deploy/sealos/charts/jotlin.values.yaml`](./deploy/sealos/charts/jotlin.values.yaml)

Before building a Sealos image, replace all placeholder values in `deploy/sealos/charts/jotlin.values.yaml`, especially:

- `image.tag`
- `migrationJob.image.tag`
- `secretEnv.DATABASE_URL`
- `secretEnv.OPENAI_API_KEY`
- `secretEnv.JWT_SECRET`
- OAuth and S3 credentials

Then build the Sealos image from the Sealos packaging directory:

```bash
cd deploy/sealos
sealos build -t your-registry/jotlin-sealos:v0.1.0 .
```

The included `Kubefile` installs Jotlin with:

```bash
helm upgrade --install jotlin charts/jotlin \
  --namespace=jotlin \
  --create-namespace \
  -f charts/jotlin.values.yaml
```

Important notes:

- The Sealos build context expects the `charts/` layout described in the Sealos Helm chart packaging documentation
- `charts/jotlin.values.yaml` is the values file Sealos uses to resolve referenced images for packaging
- The migration job remains enabled in the Sealos example values and will run automatically before install and upgrade
- Do not build a production Sealos image with placeholder secrets left in the values file

### Vercel

The easiest way to deploy Jotlin is using the [Vercel Platform](https://vercel.com):

1. Push your code to GitHub
2. Import the repository in Vercel
3. Configure environment variables
4. Deploy

See [Next.js deployment documentation](https://nextjs.org/docs/app/building-your-application/deploying) for more details.

## Contributing

We welcome contributions from the community! Whether it's:

- 🐛 Bug reports and fixes
- ✨ New feature suggestions
- 📝 Documentation improvements
- 🎨 UI/UX enhancements

### Development Workflow

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

Please read our [Contributing Guide](CONTRIBUTING.md) for more details.

## Roadmap

- [ ] Multi-language support (Chinese, Japanese, etc.)
- [ ] Export to multiple formats (Markdown, PDF, Notion)
- [ ] Team collaboration features
- [ ] Integration with project management tools
- [ ] Custom prompt templates
- [ ] Version control for specifications

## Acknowledgments

Built with amazing open-source technologies:

- [Next.js](https://nextjs.org/) - The React Framework
- [shadcn/ui](https://ui.shadcn.com/) - Beautifully designed components
- [Vercel AI SDK](https://sdk.vercel.ai/) - The AI Toolkit for TypeScript
- [Prisma](https://www.prisma.io/) - Next-generation ORM
- [Better Auth](https://better-auth.com/) - Authentication for Next.js

---

<div align="center">
  <p>Made with ❤️ by the Jotlin team</p>
  <p>
    <a href="https://github.com/yourusername/jotlin">GitHub</a> •
    <a href="https://twitter.com/jotlin">Twitter</a> •
    <a href="https://discord.gg/jotlin">Discord</a>
  </p>
</div>
