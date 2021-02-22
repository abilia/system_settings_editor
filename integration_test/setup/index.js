const axios = require('axios').default;
const { v4: uuidv4 } = require('uuid');

const BASE_URL = 'https://whale.abilia-gbg.se/';
const supportUser = 'supportadmin';
const supportPassword = 'password!';

run(process.argv[2]);

async function run(id) {
  console.log(`Starting myAbilia setup with id: ${id}`);
  const token = await login(supportUser, supportPassword);
  const userName = `IGT${id}`;
  // Insert user with no license
  await insertUser(token, userName);
  // Insert user with license
  const userNameWithLicense = `IGTWL${id}`;
  const userId = await insertUser(token, userNameWithLicense);
  // Create license
  const licenseKey = await createLicense(token);
  // Connect license to user
  await connectLicense(token, userId, licenseKey);
  await logout(token);
}

async function connectLicense(supportUserToken, userId, licenseNumber) {
  await axios.post(`${BASE_URL}/api/v1/license/portal/${userId}/add/${licenseNumber}`, {},
    { headers: { 'X-Auth-Token': supportUserToken } });
  console.log(`Connected license ${licenseNumber} to userId ${userId}`);
}

async function createLicense(supportUserToken) {
  // Get all license types
  const licenseDatas = await axios.get(`${BASE_URL}/api/v1/license/admin/data`,
    { headers: { 'X-Auth-Token': supportUserToken } });

  const licenseDataId = licenseDatas.data.filter(it => it.product === 'memoplanner3')[0].id;

  const licenseData =
  {
    id: 0,
    licenseDataId: licenseDataId,
    licenseKey: "000000000000",
    demo: false,
    initialDuration: 1825,
    maxUsers: 1,
    customer: "customer",
    attachedTo: 0,
    endTime: 0,
    createdDate: 1613480051688,
    createdBy: 0,
    hansaSerial: "hansa"
  }

  const response = await axios.post(`${BASE_URL}/api/v1/license/admin/`, licenseData,
    { headers: { 'X-Auth-Token': supportUserToken } });

  const licenseKey = response.data.licenseKey;
  console.log(`Created new license: ${licenseKey}`);
  return licenseKey;
}

async function insertUser(supportUserToken, userName) {
  const json = {
    id: 0,
    type: "user",
    image: "",
    name: "test",
    username: userName,
    language: "sv",
    password: "password"
  }
  try {
    const response = await axios.post(`${BASE_URL}/api/v1/entity/admin/user/username`, json,
      { headers: { 'X-Auth-Token': supportUserToken } });
    const userId = response.data.id;
    console.log(`Inserted user with userName: ${userName} and id: ${userId}`);
    return userId;
  } catch (error) {
    console.error(error);
  }
}

async function login(userName, password) {
  const json = {
    clientId: uuidv4(),
    type: "test",
    app: "common",
    name: "integration test"
  }
  const base64 = Buffer.from(`${userName}:${password}`).toString('base64');
  const response = await axios.post(`${BASE_URL}/api/v1/auth/client/me`, json,
    { headers: { 'Authorization': `Basic ${base64}` } });
  return response.data.token;
}

async function logout(token) {
  await axios.delete(`${BASE_URL}/api/v1/auth/client`,
    { headers: { 'X-Auth-Token': token } });
}