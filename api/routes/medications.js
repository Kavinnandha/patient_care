const express = require('express');
const router = express.Router();
const Medication = require('../schemas/Medication');

// CREATE a medication
router.post('/', async (req, res) => {
  try {
    const medication = new Medication(req.body);
    const saved = await medication.save();
    res.status(201).json(saved);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// READ all medications for a profile
router.get('/profile/:profileId', async (req, res) => {
  try {
    const medications = await Medication.find({ profileId: req.params.profileId })
      .sort({ startDate: -1 });
    res.json(medications);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// READ active medications for a profile
router.get('/profile/:profileId/active', async (req, res) => {
  try {
    const medications = await Medication.find({ 
      profileId: req.params.profileId,
      active: true 
    }).sort({ startDate: -1 });
    res.json(medications);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// READ a single medication by ID
router.get('/:id', async (req, res) => {
  try {
    const medication = await Medication.findById(req.params.id);
    if (!medication) return res.status(404).json({ error: 'Medication not found' });
    res.json(medication);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// UPDATE a medication
router.put('/:id', async (req, res) => {
  try {
    const updated = await Medication.findByIdAndUpdate(
      req.params.id, 
      req.body, 
      { new: true, runValidators: true }
    );
    if (!updated) return res.status(404).json({ error: 'Medication not found' });
    res.json(updated);
  } catch (err) {
    res.status(400).json({ error: err.message });
  }
});

// DELETE a medication
router.delete('/:id', async (req, res) => {
  try {
    const deleted = await Medication.findByIdAndDelete(req.params.id);
    if (!deleted) return res.status(404).json({ error: 'Medication not found' });
    res.json({ message: 'Medication deleted successfully' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
