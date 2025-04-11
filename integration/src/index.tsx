import React from 'react';
import ReactDOM from 'react-dom/client';
import DatabricksUI from '../../rds-ui-prototype';

const root = ReactDOM.createRoot(
  document.getElementById('root') as HTMLElement
);

root.render(
  <React.StrictMode>
    <DatabricksUI />
  </React.StrictMode>
); 