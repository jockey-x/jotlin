import crypto from 'crypto'

import axios from 'axios'
import * as Minio from 'minio'

function getS3Config() {
  const endpoint = process.env.S3_ENDPOINT || 'http://localhost:9000'
  const accessKey = process.env.S3_ACCESS_KEY
  const secretKey = process.env.S3_SECRET_KEY
  const bucketName = process.env.S3_BUCKET_NAME

  if (!accessKey || !secretKey || !bucketName) {
    throw new Error('S3 is not fully configured')
  }

  const endpointUrl = new URL(endpoint.startsWith('http') ? endpoint : `https://${endpoint}`)

  return {
    endpointUrl,
    accessKey,
    secretKey,
    bucketName,
    publicUrlBase: process.env.S3_PUBLIC_URL || `${endpointUrl.protocol}//${endpointUrl.host}`,
  }
}

function getMinioClient() {
  const { endpointUrl, accessKey, secretKey } = getS3Config()

  return new Minio.Client({
    endPoint: endpointUrl.hostname,
    port: parseInt(endpointUrl.port || (endpointUrl.protocol === 'https:' ? '443' : '9000')),
    useSSL: endpointUrl.protocol === 'https:',
    accessKey,
    secretKey,
  })
}

export async function uploadAvatar(imageUrl: string): Promise<string | null> {
  try {
    const { bucketName, publicUrlBase } = getS3Config()
    const minioClient = getMinioClient()

    // Download the image using axios
    const response = await axios.get(imageUrl, {
      responseType: 'arraybuffer',
    })

    const imageBuffer = response.data
    const contentType = response.headers['content-type'] || 'image/jpeg'

    // Generate unique filename based on URL hash
    const hash = crypto.createHash('md5').update(imageUrl).digest('hex')
    const ext = contentType.split('/')[1] || 'jpg'
    const objectName = `avatars/${hash}.${ext}`

    // Upload to MinIO
    await minioClient.putObject(bucketName, objectName, Buffer.from(imageBuffer), imageBuffer.byteLength, {
      'Content-Type': contentType,
      'Cache-Control': 'public, max-age=31536000',
    })

    // Return public URL
    const publicUrl = `${publicUrlBase}/${bucketName}/${objectName}`
    return publicUrl
  } catch (error) {
    console.error('Failed to upload avatar to MinIO:', error)
    return null
  }
}
