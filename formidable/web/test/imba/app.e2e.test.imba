const { current } = require '../storage/framework/address.json'
const { SuperTest, Response } = require 'supertest'
const request = require 'supertest'

describe 'Application (e2e)', do
	let app\SuperTest

	beforeAll do app = request current

	it '/ (GET: Welcome)', do
		const response\Response = await app.get '/'

		expect(response.status).toEqual(200)
		expect(response.text).toContain('Yey! You have successfully created a new Formidable project.')
