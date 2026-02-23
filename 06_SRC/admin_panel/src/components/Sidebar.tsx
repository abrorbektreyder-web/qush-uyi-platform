import React from 'react';
import { NavLink } from 'react-router-dom';
import { LayoutDashboard, CheckCircle, Store, Settings, LogOut } from 'lucide-react';

interface SidebarProps {
    onLogout: () => void;
}

export const Sidebar: React.FC<SidebarProps> = ({ onLogout }) => {
    const activeStyle = {
        color: 'var(--primary)',
        backgroundColor: 'rgba(0, 255, 135, 0.05)',
        borderRight: '3px solid var(--primary)',
    };

    const linkStyle = {
        display: 'flex',
        alignItems: 'center',
        gap: '16px',
        padding: '16px 32px',
        textDecoration: 'none',
        color: 'var(--text-muted)',
        fontSize: '1rem',
        fontWeight: 500,
        transition: 'all 0.2s',
    };

    return (
        <aside className="sidebar">
            <div style={{ padding: '0 32px 32px 32px', borderBottom: '1px solid var(--border-glass)', marginBottom: '16px' }}>
                <h2 style={{ color: 'var(--text-main)', display: 'flex', alignItems: 'center', gap: '10px' }}>
                    <span style={{ color: 'var(--primary)' }}>QUSH</span> UYI
                </h2>
                <p style={{ color: 'var(--text-muted)', fontSize: '0.8rem', marginTop: '4px' }}>Admin Portal 2.0</p>
            </div>

            <nav style={{ flex: 1 }}>
                <NavLink to="/" style={({ isActive }) => (isActive ? { ...linkStyle, ...activeStyle } : linkStyle)}>
                    <LayoutDashboard size={20} /> Dashboard
                </NavLink>
                <NavLink to="/verifications" style={({ isActive }) => (isActive ? { ...linkStyle, ...activeStyle } : linkStyle)}>
                    <CheckCircle size={20} /> Verifikatsiya (AI)
                </NavLink>
                <NavLink to="/shop" style={({ isActive }) => (isActive ? { ...linkStyle, ...activeStyle } : linkStyle)}>
                    <Store size={20} /> Do'kon (Ombor)
                </NavLink>
                <NavLink to="/settings" style={({ isActive }) => (isActive ? { ...linkStyle, ...activeStyle } : linkStyle)}>
                    <Settings size={20} /> Sozlamalar
                </NavLink>
            </nav>

            <div style={{ padding: '0 32px' }}>
                <button className="btn btn-danger" style={{ width: '100%', justifyContent: 'flex-start' }} onClick={onLogout}>
                    <LogOut size={20} /> Chiqish
                </button>
            </div>
        </aside>
    );
};
