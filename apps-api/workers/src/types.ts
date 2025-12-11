/**
 * Type definitions for Escriturashoy API
 */

export interface Lead {
  id: string;
  name: string;
  email: string;
  phone: string | null;
  property_location: string;
  property_type: 'casa' | 'departamento' | 'terreno' | 'comercial';
  urgency: 'alta' | 'media' | 'baja' | null;
  status: 'nuevo' | 'contactado' | 'convertido' | 'perdido';
  notes: string | null;
  created_at: number;
  updated_at: number;
}

export interface Expediente {
  id: string;
  client_id: string;
  lead_id: string | null;
  property_location: string;
  type: 'compraventa' | 'donacion' | 'sucesion' | 'otro';
  status: 'inicial' | 'documentacion' | 'revision' | 'firma' | 'cerrado' | 'cancelado';
  metadata: string | null;
  created_at: number;
  updated_at: number;
  // Joined fields
  client_name?: string;
  client_email?: string;
  lead_name?: string;
}

export interface CreateLeadRequest {
  name: string;
  email: string;
  phone?: string;
  property_location: string;
  property_type: 'casa' | 'departamento' | 'terreno' | 'comercial';
  urgency?: 'alta' | 'media' | 'baja';
}

export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  error?: string;
  message?: string;
}

