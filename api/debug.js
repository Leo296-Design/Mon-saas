module.exports = (req, res) => {
  const raw = process.env.ANTHROPIC_API_KEY || '';
  const trimmed = raw.trim();
  res.status(200).json({
    hasKey: !!trimmed,
    rawLength: raw.length,
    trimmedLength: trimmed.length,
    prefix: trimmed.slice(0, 15),
    suffix: trimmed.slice(-4)
  });
};
