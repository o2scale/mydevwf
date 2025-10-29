#!/usr/bin/env node

/**
 * Project Creation Script
 * Usage: node scripts/create-project.js <template> <project-name>
 * Example: node scripts/create-project.js nextjs-nodejs-supabase my-new-app
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// Configuration
const TEMPLATES_DIR = path.join(__dirname, '..', 'project-templates');
const TEMPLATES = ['nextjs-nodejs-supabase', 'nextjs-nodejs-mongodb', 'nextjs-fastapi-supabase', 'react-native-mobile'];

// Parse arguments
const args = process.argv.slice(2);
if (args.length !== 2) {
  console.error('❌ Usage: node scripts/create-project.js <template> <project-name>');
  console.error('\nAvailable templates:');
  TEMPLATES.forEach(t => console.error(`  - ${t}`));
  process.exit(1);
}

const [template, projectName] = args;

// Validate template
if (!TEMPLATES.includes(template)) {
  console.error(`❌ Invalid template: ${template}`);
  console.error('\nAvailable templates:');
  TEMPLATES.forEach(t => console.error(`  - ${t}`));
  process.exit(1);
}

// Validate project name
if (!/^[a-z0-9-]+$/.test(projectName)) {
  console.error('❌ Project name must contain only lowercase letters, numbers, and hyphens');
  process.exit(1);
}

const templatePath = path.join(TEMPLATES_DIR, template);
const projectPath = path.join(process.cwd(), '..', projectName);

// Check if template exists
if (!fs.existsSync(templatePath)) {
  console.error(`❌ Template not found: ${templatePath}`);
  process.exit(1);
}

// Check if project already exists
if (fs.existsSync(projectPath)) {
  console.error(`❌ Project already exists: ${projectPath}`);
  process.exit(1);
}

console.log(`\n🚀 Creating project: ${projectName}`);
console.log(`📋 Template: ${template}\n`);

// Copy template
try {
  console.log('📁 Copying template files...');
  execSync(`xcopy "${templatePath}" "${projectPath}" /E /I /H /Y`, { stdio: 'inherit' });
  console.log('✅ Template files copied\n');
} catch (error) {
  console.error('❌ Failed to copy template:', error.message);
  process.exit(1);
}

// Copy .bmad-core from parent
const bmadCorePath = path.join(__dirname, '..', '.bmad-core');
const projectBmadCorePath = path.join(projectPath, '.bmad-core');

if (fs.existsSync(bmadCorePath)) {
  console.log('📁 Copying BMad framework...');
  try {
    execSync(`xcopy "${bmadCorePath}" "${projectBmadCorePath}" /E /I /H /Y`, { stdio: 'inherit' });
    console.log('✅ BMad framework copied\n');
  } catch (error) {
    console.error('⚠️  Warning: Could not copy BMad framework:', error.message);
  }
}

// Create .claude/settings.local.json from example
const settingsExample = path.join(projectPath, '.claude', 'settings.local.json.example');
const settingsLocal = path.join(projectPath, '.claude', 'settings.local.json');

if (fs.existsSync(settingsExample) && !fs.existsSync(settingsLocal)) {
  console.log('📝 Creating .claude/settings.local.json...');
  fs.copyFileSync(settingsExample, settingsLocal);
  console.log('✅ Settings file created\n');
}

// Update package.json project name (if exists)
const packageJsonPath = path.join(projectPath, 'package.json');
if (fs.existsSync(packageJsonPath)) {
  console.log('📝 Updating package.json...');
  const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, 'utf8'));
  packageJson.name = projectName;
  fs.writeFileSync(packageJsonPath, JSON.stringify(packageJson, null, 2));
  console.log('✅ package.json updated\n');
}

console.log('✨ Project created successfully!\n');
console.log('📌 Next steps:\n');
console.log(`   cd ../${projectName}`);
console.log('   npm install  (or: pip install -r backend/requirements.txt for Python)');
console.log('   # Configure .env files');
console.log('   npm run dev\n');
console.log(`📖 Read the README.md for detailed setup instructions`);
console.log(`🔍 Verify MCPs with: /mcp in Claude Code\n`);
