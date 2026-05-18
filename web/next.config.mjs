/** @type {import('next').NextConfig} */
const nextConfig = {
  typescript: {
    ignoreBuildErrors: true,
  },
  images: {
    unoptimized: true,
  },
  // fflate's package.json `exports` map routes `require + node` resolution to
  // ./lib/node.cjs, which contains `new Worker(c + workerAdd, { eval: true })`
  // — unresolvable by Turbopack. fflate exposes a `./browser` subpath that
  // points at the safe ESM entry; alias the bare import to that.
  turbopack: {
    resolveAlias: {
      fflate: 'fflate/browser',
    },
  },
}

export default nextConfig
