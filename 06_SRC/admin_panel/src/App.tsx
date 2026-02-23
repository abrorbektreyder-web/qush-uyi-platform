
import { Routes, Route } from 'react-router-dom';
import { Sidebar } from './components/Sidebar';
import { Dashboard } from './pages/Dashboard';
import { VerificationCenter } from './pages/VerificationCenter';
import { ShopManager } from './pages/ShopManager';
import { Settings } from './pages/Settings';
import './modal.css';

function App() {
  return (
    <div className="app-layout">
      {/* Sidebar Navigation */}
      <Sidebar />

      {/* Main Content Render Area */}
      <main className="main-content">
        <Routes>
          <Route path="/" element={<Dashboard />} />
          <Route path="/verifications" element={<VerificationCenter />} />
          <Route path="/shop" element={<ShopManager />} />
          <Route path="/settings" element={<Settings />} />
        </Routes>
      </main>
    </div>
  );
}

export default App;
