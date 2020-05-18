import 'abortcontroller-polyfill/dist/abortcontroller-polyfill-only';
import { configure } from '@superset-ui/translation';
import setupClient from './setup/setupClient';
import setupColors from './setup/setupColors';
import localStorage from 'local-storage'

// Configure translation
if (typeof window !== 'undefined') {
  const root = document.getElementById('app');
  const bootstrapData = root ? JSON.parse(root.getAttribute('data-bootstrap')) : {};
  if (bootstrapData.common && bootstrapData.common.language_pack) {
    const languagePack = bootstrapData.common.language_pack;
    configure({ languagePack });
    localStorage.set('locale', bootstrapData.common.locale);
  } else {
    configure();
  }
} else {
  configure();
}

// Setup SupersetClient
setupClient();

// Setup color palettes
setupColors();
