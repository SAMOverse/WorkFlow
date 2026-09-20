// Placeholder function, proves the Netlify Functions layer is wired up.
// Delete once a real function exists -- this isn't meant to survive.
export const handler = async () => ({
  statusCode: 200,
  body: JSON.stringify({ status: 'ok', service: 'workflow' }),
});
